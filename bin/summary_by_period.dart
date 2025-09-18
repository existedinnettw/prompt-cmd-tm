import 'package:dart_mcp/server.dart';

/// Transcript summary prompt implementation
class TranscriptSummaryPrompt {
  /// The transcript summary prompt definition
  static final prompt = Prompt(
    name: 'summary_by_period',
    description:
        'Summarize discussion transcripts by topics within time periods',
    arguments: [
      PromptArgument(
        name: 'file_path',
        description: 'A transcript file to summarize',
        required: true,
      ),
      PromptArgument(
        name: 'additional_condition',
        description:
            'Additional conditions or instructions for the summarization',
        required: false,
      ),
    ],
  );

  /// Transcript summary prompt implementation
  static GetPromptResult generate(GetPromptRequest request) {
    final filePath = request.arguments?['file_path'] as String?;
    final additionalCondition =
        request.arguments?['additional_condition'] as String? ?? '';

    if (filePath == null) {
      return GetPromptResult(
        description: 'Transcript summarization',
        messages: [
          PromptMessage(
            role: Role.user,
            content: TextContent(text: 'Error: No file path provided'),
          ),
        ],
      );
    }

    // Load the transcript summary prompt text
    final promptText = _loadPromptText();

    // Replace placeholders in the prompt
    final customizedPrompt = promptText
        .replaceAll('{file_path}', filePath)
        .replaceAll('{additional_condition}', additionalCondition);

    return GetPromptResult(
      description: 'Discussion transcript summarization',
      messages: [
        PromptMessage(
          role: Role.user,
          content: TextContent(text: customizedPrompt),
        ),
      ],
    );
  }

  static String _loadPromptText() {
    // try not fix the output format
    return """
附檔 `{file_path}` 是討論的逐字稿。請幫我把內容按某一時間段內的討論主題作區隔，並總結每一個討論主題的摘要。

{additional_condition}
""";
  }
}
