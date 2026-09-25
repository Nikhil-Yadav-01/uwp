import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/archetypes/archetype_registry.dart';
import '../../../../core/archetypes/contracts/archetype_feature_handler.dart';
import '../../../../core/archetypes/models/archetype_definition.dart';

/// State containing the current active business archetype and its strategy handler
class ArchetypeState {
  final BusinessArchetype archetype;
  final IArchetypeFeatureHandler handler;
  final List<Map<String, dynamic>> products;

  const ArchetypeState({
    required this.archetype,
    required this.handler,
    required this.products,
  });

  ArchetypeState copyWith({
    BusinessArchetype? archetype,
    IArchetypeFeatureHandler? handler,
    List<Map<String, dynamic>>? products,
  }) {
    return ArchetypeState(
      archetype: archetype ?? this.archetype,
      handler: handler ?? this.handler,
      products: products ?? this.products,
    );
  }
}

/// Notifier managing live active archetype switching during client demo showcase
class ArchetypeNotifier extends StateNotifier<ArchetypeState> {
  ArchetypeNotifier()
      : super(
          ArchetypeState(
            archetype: ArchetypeRegistry.getArchetype(BusinessArchetypeType.leatherAndTextiles),
            handler: ArchetypeRegistry.getHandler(BusinessArchetypeType.leatherAndTextiles),
            products: ArchetypeRegistry.getHandler(BusinessArchetypeType.leatherAndTextiles).getDemoProducts(),
          ),
        );

  /// 1-Click switch to any business archetype
  void switchArchetype(BusinessArchetypeType type) {
    final newArchetype = ArchetypeRegistry.getArchetype(type);
    final newHandler = ArchetypeRegistry.getHandler(type);
    final demoProducts = newHandler.getDemoProducts();

    state = ArchetypeState(
      archetype: newArchetype,
      handler: newHandler,
      products: demoProducts,
    );
  }
}

/// Global provider for the active archetype state
final archetypeProvider = StateNotifierProvider<ArchetypeNotifier, ArchetypeState>((ref) {
  return ArchetypeNotifier();
});
