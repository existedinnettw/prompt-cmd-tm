import 'dart:io' as io;

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

void main() {
  // Create the server and connect it to stdio.
  PersonWeekReportServer(stdioChannel(input: io.stdin, output: io.stdout));
}

/// MCP server for generating personal weekly reports.
base class PersonWeekReportServer extends MCPServer with PromptsSupport {
  PersonWeekReportServer(super.channel)
    : super.fromStreamChannel(
        implementation: Implementation(
          name: 'Personal Weekly Report Generator',
          version: '1.0.0',
        ),
        instructions:
            'Use the person_week_report prompt to generate weekly reports from messages.',
      ) {
    // Add the prompt
    addPrompt(personWeekReportPrompt, _generateWeekReportPrompt);
  }

  /// The prompt implementation
  GetPromptResult _generateWeekReportPrompt(GetPromptRequest request) {
    final messages = request.arguments?['messages'] as String?;
    final userName = request.arguments?['user_name'] as String? ?? 'User';

    if (messages == null) {
      return GetPromptResult(
        description: 'Weekly report generation',
        messages: [
          PromptMessage(
            role: Role.user,
            content: TextContent(text: 'Error: No messages provided'),
          ),
        ],
      );
    }

    // Load the prompt text
    final promptText = _loadPromptText();

    // Replace placeholders in the prompt
    final customizedPrompt = promptText
        .replaceAll('{user_name}', userName)
        .replaceAll('{YYYYMMDD}', _getCurrentDate());

    return GetPromptResult(
      description: 'Personal weekly report generation',
      messages: [
        PromptMessage(
          role: Role.user,
          content: TextContent(
            text: '$customizedPrompt\n\nMessages:\n$messages',
          ),
        ),
      ],
    );
  }

  String _loadPromptText() {
    return """
# Task: Generate a personal weekly report

1. There are messages in context. 
  * Some of them are commit messages from remote git webhooks, some are personal notes or thoughts.
2. For any non-markdown context, please convert them to markdown format with `markitdown` (MCP) tool first.
3. Please summarize them into a weekly report in zh-TW(繁體中文) and markdown. 
4. Finally save to a file named `{user_name}工作報告-{YYYYMMDD}.draft.md`
  * e.g. `吳名氏工作報告-20250828.draft.md`
  * `YYYYMMDD` is the date of the last message in context.
  * {user_name} can get from !{whoami}.

## report format

Following is a sample of formatted report.

```mermaid
# 週報

## Running

* iMotion-3dof
  1. Improve puppemon
     1. Puppemon 新增 subscribe executor server state 功能。
     
     2. Puppemon_py_script 新增 確定達到 等待點的功能。
* <other project>
  1. <task>
     1. <detail>
     2. <detail>(no more than 4 details)
  2. <task>(no more than 4 tasks)
     1. <subtask>
         1. <detail>
         2. <detail>
* 其他
  1. LLM AI coding
     1. gen-report
        1. 可自動整合週報大綱
     2. CLI/lib based
        1. 在 puppemon repo 實踐
     3. GUI based
        1. 部份可行，需要再改進
        2. pdf_signature repo 實踐

## Holding

* <Holding project>(if really needed)
  1. <task>
     1. <detail>
     2. <detail>

```

* should not more than 4 items in each section (list and sub-list).
* Projects list is provided below, please classify the messages into relevant projects.
* <Holding project> imply they are on hold, we just need to keep track of them.
    * Usually just left "## Holding" section empty.

### Projects list

Following are project running or holding and its relevant keywords, which may help you to classify the messages:

* iMotion-3dof
  * GUI
    * 'codegg'
    * 'Resymot GUI'
  * 腳本
    * 'puppemon'
    * 'puppemon_py_script'
  * 'imotion', 'Resymot', 'iMotion-XYZ控制器'... 也都屬於'iMotion-3dof'
* 螺絲案
  * 'BONY觸控一體機','得鑫螺絲','得鑫螺絲HMI','EBONY觸控一體機'...
* 教育訓練
  * '育成計畫', '新人訓練'...
* other than above, plz classify to "其他"

### Steps

1. classify messages into relevant projects
2. extract (1~4) key points from messages
3. generate report based on classified messages

""";
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  /// The prompt definition
  static final personWeekReportPrompt = Prompt(
    name: 'person_week_report',
    description: 'Generate a personal weekly report based on messages',
    arguments: [
      PromptArgument(
        name: 'messages',
        description: 'The messages to analyze for the weekly report',
        required: true,
      ),
      PromptArgument(
        name: 'user_name',
        description: 'The user name for the report',
        required: false,
      ),
    ],
  );
}
