import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:moor_generator/src/backends/plugin/services/requests.dart';
import 'package:sqlparser/sqlparser.dart';

part 'column_nullability.dart';

class AssistService implements AssistContributor {
  const AssistService();

  final _nullability = const ColumnNullability();

  @override
  void computeAssists(AssistRequest request, AssistCollector collector) {
    final moorRequest = request as MoorAssistRequest;
    final parseResult = moorRequest.task.lastResult.parseResult;
    final relevantNodes =
        parseResult.findNodesAtPosition(request.offset, length: request.length);

    for (var node in relevantNodes.expand((node) => node.selfAndParents)) {
      _handleNode(collector, node, moorRequest.task.path);
    }
  }

  void _handleNode(AssistCollector collector, AstNode node, String path) {
    if (node is ColumnDefinition) {
      _nullability.contribute(collector, node, path);
    }
  }
}

abstract class _AssistOnNodeContributor<T extends AstNode> {
  const _AssistOnNodeContributor();

  void contribute(AssistCollector collector, T node, String path);
}

class AssistId {
  final String id;
  final int priority;

  const AssistId._(this.id, this.priority);

  static const makeNullable = AssistId._('make_column_nullable', 100);
  static const makeNotNull = AssistId._('make_column_not_nullable', 10);
}
