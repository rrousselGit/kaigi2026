import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:riverpod_analyzer_utils/riverpod_analyzer_utils.dart';

final plugin = LintsPlugin();

class LintsPlugin extends Plugin {
  @override
  String get name => 'lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(AvoidHardcodedStringRule());
    registry.registerWarningRule(MustSpecifyProviderNameRule());
  }
}

class AvoidHardcodedStringRule extends AnalysisRule {
  static const _code = LintCode(
    'avoid_hardcoded_string',
    'Avoid hardcoded strings inside Widget subclasses.',
    correctionMessage:
        'Try extracting the string literal to a constant or localized resource.',
  );

  AvoidHardcodedStringRule()
    : super(name: _code.lowerCaseName, description: _code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);
    registry.addSimpleStringLiteral(this, visitor);
    registry.addStringInterpolation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidHardcodedStringRule rule;

  _Visitor(this.rule);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _checkStringLiteral(node);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _checkStringLiteral(node);
  }

  void _checkStringLiteral(StringLiteral node) {
    final classNode = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classNode == null) return;

    if (_isWidgetSubclass(classNode)) {
      rule.reportAtNode(node);
    }
  }

  bool _isWidgetSubclass(ClassDeclaration classNode) {
    final element = classNode.declaredFragment?.element;
    if (element != null) {
      if (element.name == 'Widget') return true;
      for (final type in element.allSupertypes) {
        if (type.element.name == 'Widget') {
          return true;
        }
      }
    }

    final extendsClause = classNode.extendsClause;
    if (extendsClause != null) {
      final superName = extendsClause.superclass.name.lexeme;
      if (superName == 'Widget' ||
          superName == 'StatelessWidget' ||
          superName == 'StatefulWidget' ||
          superName == 'InheritedWidget') {
        return true;
      }
    }
    return false;
  }
}

class MustSpecifyProviderNameRule extends AnalysisRule {
  static const _code = LintCode(
    'must_specify_provider_name',
    'Providers must specify a name parameter.',
    correctionMessage:
        'Try specifying a "name" parameter when declaring a provider.',
  );

  MustSpecifyProviderNameRule()
    : super(name: _code.lowerCaseName, description: _code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _MustSpecifyProviderNameVisitor(this);
    registry.addVariableDeclaration(this, visitor);
  }
}

class _MustSpecifyProviderNameVisitor extends SimpleAstVisitor<void> {
  final MustSpecifyProviderNameRule rule;

  _MustSpecifyProviderNameVisitor(this.rule);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final provider = node.provider;
    if (provider is ManualProviderDeclaration) {
      final hasNameArg = provider.argumentList.arguments.any((arg) {
        if (arg is NamedArgument) {
          return arg.name.lexeme == 'name';
        }
        return false;
      });

      if (!hasNameArg) {
        rule.reportAtNode(node);
      }
    }
  }
}
