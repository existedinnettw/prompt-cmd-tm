import 'dart:io' as io;

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

import 'tm/person_week_report_prompt.dart';
import 'summary_by_period.dart';

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
            'Use the person_week_report prompt to generate weekly reports from a log file.',
      ) {
    // Add the prompts
    addPrompt(PersonWeekReportPrompt.prompt, PersonWeekReportPrompt.generate);
    addPrompt(TranscriptSummaryPrompt.prompt, TranscriptSummaryPrompt.generate);
  }
}
