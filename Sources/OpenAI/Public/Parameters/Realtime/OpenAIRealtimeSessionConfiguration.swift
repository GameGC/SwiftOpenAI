// MARK: - OpenAIRealtimeSessionConfiguration

//
//  OpenAIRealtimeSessionConfiguration.swift
//  SwiftOpenAI
//
//  Created from AIProxySwift
//  Original: https://github.com/lzell/AIProxySwift
//

/// Realtime session configuration
/// https://platform.openai.com/docs/api-reference/realtime-client-events/session/update
public struct OpenAIRealtimeSessionConfiguration: Encodable, Sendable {

    // MARK: - Init

    public init(
        audio: AudioConfig? = nil,
        instructions: String? = nil,
        maxResponseOutputTokens: MaxResponseOutputTokens? = nil,
        modalities: [Modality]? = nil,
        prompt:Prompt? = nil,
        reasoning: Reasoning? = nil,
        temperature: Double? = nil,
        tools: [RealtimeTool]? = nil,
        toolChoice: ToolChoice? = nil,
        turnDetection: TurnDetection? = nil,
        sessionType: String? = "realtime"
    ) {
        self.audio = audio
        self.instructions = instructions
        self.maxResponseOutputTokens = maxResponseOutputTokens
        self.modalities = modalities
        self.temperature = temperature
        self.tools = tools
        self.toolChoice = toolChoice
        self.turnDetection = turnDetection
        self.prompt = prompt
        self.reasoning = reasoning
        self.sessionType = sessionType
    }

    // MARK: - Stored Properties

    /// The type of session. Always "realtime" for the Realtime API.
    public let sessionType: String?

    /// Nested audio input/output configuration.
    /// Contains format, speed, voice, noise reduction, and transcription settings.
    public let audio: AudioConfig?

    /// The default system instructions prepended to model calls.
    public let instructions: String?

    /// Maximum number of output tokens for a single assistant response.
    /// Provide an integer between 1 and 4096, or `.infinite` for the model's maximum.
    public let maxResponseOutputTokens: MaxResponseOutputTokens?

    /// The set of modalities the model can respond with.
    /// Use `[.audio]` for audio-only. Use `[.text]` for text-only.
    /// Audio and text cannot be requested simultaneously.
    public let modalities: [Modality]?

    public let prompt: Prompt?
    
    public let reasoning: Reasoning?
    
    /// Sampling temperature for the model.
    public let temperature: Double?

    /// Tools (functions and MCP servers) available to the model.
    public let tools: [RealtimeTool]?

    /// How the model chooses tools.
    public let toolChoice: ToolChoice?

    /// Configuration for turn detection. Set to `nil` to turn off (push-to-talk mode).
    public let turnDetection: TurnDetection?

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case audio
        case instructions
        case maxResponseOutputTokens = "max_response_output_tokens"
        case modalities = "output_modalities"
        case prompt
        case reasoning
        case temperature
        case tools
        case toolChoice = "tool_choice"
        case turnDetection = "turn_detection"
        case sessionType = "type"
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.AudioConfig

extension OpenAIRealtimeSessionConfiguration {

    /// Top-level audio configuration wrapping input and output settings.
    public struct AudioConfig: Encodable, Sendable {
        public let input: AudioInput?
        public let output: AudioOutput?

        public init(input: AudioInput? = nil, output: AudioOutput? = nil) {
            self.input = input
            self.output = output
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.AudioInput

extension OpenAIRealtimeSessionConfiguration {

    /// Configuration for input audio (microphone side).
    public struct AudioInput: Encodable, Sendable {
        /// The PCM format of the input audio. Defaults to `audio/pcm` (24 kHz mono).
        public let format: AudioFormatConfig?

        /// Noise reduction applied before VAD and the model.
        /// Use `.nearField` for headphones/earbuds, `.farField` for laptop or room mics.
        /// Set to `nil` to disable.
        public let noiseReduction: NoiseReduction?

        /// Input audio transcription configuration.
        /// Transcription runs asynchronously and should be treated as a guidance signal,
        /// not a precise record of what the model heard.
        public let transcription: InputAudioTranscription?

        public init(
            format: AudioFormatConfig? = nil,
            noiseReduction: NoiseReduction? = nil,
            transcription: InputAudioTranscription? = nil
        ) {
            self.format = format
            self.noiseReduction = noiseReduction
            self.transcription = transcription
        }

        private enum CodingKeys: String, CodingKey {
            case format
            case noiseReduction = "noise_reduction"
            case transcription
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.AudioOutput

extension OpenAIRealtimeSessionConfiguration {

    /// Configuration for output audio (speaker side).
    public struct AudioOutput: Encodable, Sendable {
        /// The PCM format of the output audio. Defaults to `audio/pcm` (24 kHz mono).
        public let format: AudioFormatConfig?

        /// Playback speed as a multiple of normal speed.
        /// Valid range: **0.25 – 1.5**. Default is 1.0.
        /// Applied as a post-processing step after audio generation.
        /// You can also prompt the model to "speak faster" or "speak slower" via instructions.
        public let speed: Float?

        /// The voice the model uses to respond.
        /// Built-in voices: alloy, ash, ballad, coral, echo, sage, shimmer, verse, marin, cedar.
        /// OpenAI recommends **marin** and **cedar** for best quality.
        /// Cannot be changed once the model has responded with audio.
        public let voice: String?

        public init(
            format: AudioFormatConfig? = nil,
            speed: Float? = nil,
            voice: String? = nil
        ) {
            self.format = format
            self.speed = speed
            self.voice = voice
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.AudioFormatConfig

extension OpenAIRealtimeSessionConfiguration {

    /// Audio format object. The API expects an object `{ "type": "audio/pcm" }`,
    /// not a plain string. Only 24 kHz mono is supported for PCM.
    public struct AudioFormatConfig: Encodable, Sendable {
        /// The MIME-style audio format string.
        public let type: String
        public let rate: Int?      // ← add this; required for audio/pcm, not used for pcmu/pcma

          public init(_ type: String = "audio/pcm", rate: Int? = nil) {
              self.type = type
              self.rate = rate
          }
        /// Standard PCM 16-bit 24 kHz mono — the format used by StreamingAudioPlayer.
        public static let pcm = AudioFormatConfig("audio/pcm",rate: 24000)
        /// G.711 μ-law
        public static let pcmu = AudioFormatConfig("audio/pcmu")
        /// G.711 A-law
        public static let pcma = AudioFormatConfig("audio/pcma")
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.NoiseReduction

extension OpenAIRealtimeSessionConfiguration {

    /// Noise reduction applied to microphone input before VAD and the model.
    public struct NoiseReduction: Encodable, Sendable {

        public enum NRType: String, Encodable, Sendable {
            /// For close-talking microphones such as headphones or earbuds.
            case nearField = "near_field"
            /// For far-field microphones such as laptop built-ins or conference room mics.
            case farField  = "far_field"
        }

        public let type: NRType

        public init(_ type: NRType) {
            self.type = type
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.InputAudioTranscription

extension OpenAIRealtimeSessionConfiguration {

    /// Configuration for asynchronous input audio transcription.
    /// Transcription is not native to the model — it runs via /audio/transcriptions
    /// and should be treated as a guidance signal rather than a precise transcript.
    public struct InputAudioTranscription: Encodable, Sendable {

        /// The transcription model to use.
        /// Options: "whisper-1", "gpt-4o-mini-transcribe", "gpt-4o-transcribe",
        ///          "gpt-4o-transcribe-diarize" (includes speaker labels),
        ///          "gpt-realtime-whisper"
        public let model: String

        /// The language of the input audio in ISO-639-1 format (e.g. "en", "es", "ja").
        /// Improves accuracy and latency.
        public let language: String?

        /// Optional text to guide the model's style or continue a previous segment.
        /// For whisper-1, this is a list of keywords.
        /// For gpt-4o-transcribe models, this is a free-text string.
        public let prompt: String?

        public init(model: String, language: String? = nil, prompt: String? = nil) {
            self.model = model
            self.language = language
            self.prompt = prompt
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.MaxResponseOutputTokens

extension OpenAIRealtimeSessionConfiguration {

    public enum MaxResponseOutputTokens: Encodable, Sendable {
        /// A specific token limit between 1 and 4096.
        case int(Int)
        /// No limit — use the model's maximum context.
        case infinite

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let value): try container.encode(value)
            case .infinite:       try container.encode("inf")
            }
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.Modality

extension OpenAIRealtimeSessionConfiguration {

    /// The output modality. Audio and text cannot be used simultaneously.
    public enum Modality: String, Encodable, Sendable {
        /// Audio output (with implicit transcript).
        case audio
        /// Text-only output.
        case text
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.ToolChoice

extension OpenAIRealtimeSessionConfiguration {

    public enum ToolChoice: Encodable, Sendable {
        /// The model will not call any tool and instead generates a message.
        /// This is the default when no tools are present.
        case none

        /// The model can pick between generating a message or calling one or more tools.
        /// This is the default when tools are present.
        case auto

        /// The model must call one or more tools.
        case required

        /// Forces the model to call a specific function tool.
        case specific(functionName: String)

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .none:
                var c = encoder.singleValueContainer()
                try c.encode("none")
            case .auto:
                var c = encoder.singleValueContainer()
                try c.encode("auto")
            case .required:
                var c = encoder.singleValueContainer()
                try c.encode("required")
            case .specific(let functionName):
                var c = encoder.container(keyedBy: RootKey.self)
                try c.encode("function", forKey: .type)
                try c.encode(functionName, forKey: .name)
            }
        }

        private enum RootKey: CodingKey {
            case type
            case name
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.FunctionTool

extension OpenAIRealtimeSessionConfiguration {

    public struct FunctionTool: Encodable, Sendable {
        public let description: String
        public let name: String
        public let parameters: [String: OpenAIJSONValue]
        public let type = "function"

        public init(name: String, description: String, parameters: [String: OpenAIJSONValue]) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.RealtimeTool

extension OpenAIRealtimeSessionConfiguration {

    /// A tool available to the model — either a local function or a remote MCP server.
    public enum RealtimeTool: Encodable, Sendable {
        case function(FunctionTool)
        case mcp(Tool.MCPTool)

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .function(let tool):  try tool.encode(to: encoder)
            case .mcp(let mcpTool):    try mcpTool.encode(to: encoder)
            }
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.TurnDetection

extension OpenAIRealtimeSessionConfiguration {

    /// Configuration for automatic turn detection.
    /// Set to `nil` in the session config to use push-to-talk (manual commit) mode.
    public struct TurnDetection: Encodable, Sendable {

        public init(type: DetectionType) {
            self.type = type
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch type {
            case .serverVAD(let prefixPaddingMs, let silenceDurationMs, let threshold):
                try container.encode("server_vad",     forKey: .type)
                try container.encode(prefixPaddingMs,  forKey: .prefixPaddingMs)
                try container.encode(silenceDurationMs,forKey: .silenceDurationMs)
                try container.encode(threshold,         forKey: .threshold)

            case .semanticVAD(let eagerness):
                try container.encode("semantic_vad",            forKey: .type)
                try container.encode(String(describing: eagerness), forKey: .eagerness)
            }
        }

        let type: DetectionType

        private enum CodingKeys: String, CodingKey {
            case prefixPaddingMs   = "prefix_padding_ms"
            case silenceDurationMs = "silence_duration_ms"
            case threshold
            case type
            case eagerness
        }
    }
}

// MARK: - OpenAIRealtimeSessionConfiguration.TurnDetection.DetectionType

extension OpenAIRealtimeSessionConfiguration.TurnDetection {

    public enum DetectionType: Encodable, Sendable {

        /// Classic volume-based VAD.
        /// - Parameters:
        ///   - prefixPaddingMs: Audio to include before speech starts. OpenAI default: 300 ms.
        ///   - silenceDurationMs: Silence needed to end a turn. OpenAI default: 500 ms.
        ///   - threshold: VAD activation threshold (0.0–1.0). OpenAI default: 0.5.
        ///                Higher = louder audio needed; better in noisy environments.
        case serverVAD(prefixPaddingMs: Int, silenceDurationMs: Int, threshold: Double)

        /// Model-based semantic VAD — waits until the user has semantically finished speaking.
        /// Higher latency than serverVAD but fewer false positives on trailing speech.
        /// - Parameters:
        ///   - eagerness: `low` (≤8 s), `medium`/`auto` (≤4 s), `high` (≤2 s). Default: auto.
        case semanticVAD(eagerness: Eagerness)

        public enum Eagerness: String, Encodable, Sendable {
            case low
            case medium
            case high
            case auto
        }
    }
}
