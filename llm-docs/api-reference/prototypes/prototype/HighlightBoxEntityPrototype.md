# HighlightBoxEntityPrototype

Used to attach graphics for [cursor boxes](prototype:CursorBoxType) to entities during runtime. HighlightBoxEntity can also be independent from entities so it is simply drawn somewhere in the world. See [LuaSurface::create_entity](runtime:LuaSurface::create_entity) for the available options for type "highlight-box".

The [collision_box](prototype:EntityPrototype::collision_box) of the highlight box prototype is ignored during runtime, instead the "bounding_box" given in create_entity() or the selection box of the target entity is used.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `highlight-box`

