//
//  NetworkRetryPolicy.swift
//  SwiftOpenAI
//
//  Fast, minimal-delay retry for transient network interruptions.
//  Tuned for "recover as fast as possible" rather than "wait patiently":
//  no exponential backoff, just enough jitter to avoid hammering a
//  completely dead socket in a hard loop.
//

import Foundation


public enum NetworkRetryPolicy {

  /// Total attempts (1 initial try + up to maxAttempts-1 retries).
  public static let maxAttempts = 4

  /// Delay between attempts. Intentionally tiny - this is not backoff,
  /// it only exists to yield the thread between spins.
  public static let interAttemptDelayNanoseconds: UInt64 = 25_000_000 // 25ms

  /// Whether `error` represents a transient network condition (dropped
  /// connection, timeout, DNS blip, etc.) as opposed to a real API or
  /// programmer error (bad request, auth failure, decode failure) that
  /// retrying would never fix.
  public static func isRetryable(_ error: Error) -> Bool {
    if let urlError = error as? URLError {
      switch urlError.code {
      case .networkConnectionLost,
           .timedOut,
           .notConnectedToInternet,
           .cannotConnectToHost,
           .cannotFindHost,
           .dnsLookupFailed,
           .resourceUnavailable,
           .secureConnectionFailed,
           .dataNotAllowed,
           .internationalRoamingOff,
           .callIsActive:
        return true
      default:
        return false
      }
    }

    // AsyncHTTPClient (Linux) throws its own error types (HTTPClientError,
    // NIO channel errors, etc.) that aren't available to switch over on
    // Apple platforms. Match on description as a pragmatic fallback.
    let description = String(describing: error).lowercased()
    let transientMarkers = [
      "timeout", "timed out", "connectionclosed", "connection reset",
      "connectionreseterror", "remoteconnectionclosed", "channelerror",
      "notconnected", "connectionrefused", "connection refused",
    ]
    return transientMarkers.contains { description.contains($0) }
  }

  /// Runs `operation`, retrying immediately (with a minimal jitter) on any
  /// retryable transient network error, up to `maxAttempts` total tries.
  /// Non-retryable errors are thrown immediately without retrying.
  /// Once retries are exhausted, throws `APIError.connectionInterrupted`
  /// so callers get a consistent, typed error instead of a raw system error.
  public static func withRetry<R>(
    maxAttempts: Int = NetworkRetryPolicy.maxAttempts,
    debugEnabled: Bool = false,
    label: String = "request",
    operation: () async throws -> R)
    async throws -> R
  {
    var attempt = 1
    while true {
      do {
        return try await operation()
      } catch {
        guard isRetryable(error) else {
          throw error
        }
        guard attempt < maxAttempts else {
          throw APIError.connectionInterrupted(
            description: error.localizedDescription,
            attemptsMade: attempt)
        }
        #if DEBUG
        if debugEnabled {
          print("SwiftOpenAI: \(label) hit a transient network error, retrying (attempt \(attempt)/\(maxAttempts)): \(error)")
        }
        #endif
        attempt += 1
        try? await Task.sleep(nanoseconds: interAttemptDelayNanoseconds)
      }
    }
  }
}
