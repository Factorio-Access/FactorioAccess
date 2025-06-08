# LuaEntity

The primary interface for interacting with entities through the Lua API. Entities are everything that exists on the map except for tiles (see [LuaTile](runtime:LuaTile)).

Most functions on LuaEntity also work when the entity is contained in a ghost.

**Parent:** `LuaControl`

## Methods

### add_autopilot_destination

Adds the given position to this spidertron's autopilot's queue of destinations.

**Parameters:**

- `position` `MapPosition`: The position the spidertron should move to.

### add_market_item

Offer a thing on the market.

**Parameters:**

- `offer` `Offer`: 

### can_be_destroyed

Whether the entity can be destroyed

**Returns:**

- `boolean`: 

### can_shoot

Whether this character can shoot the given entity or position.

**Parameters:**

- `position` `MapPosition`: 
- `target` `LuaEntity`: 

**Returns:**

- `boolean`: 

### can_wires_reach

Can wires reach between these entities.

**Parameters:**

- `entity` `LuaEntity`: 

**Returns:**

- `boolean`: 

### cancel_deconstruction

Cancels deconstruction if it is scheduled, does nothing otherwise.

**Parameters:**

- `force` `ForceID`: The force who did the deconstruction order.
- `player` `PlayerIdentification` _(optional)_: The player to set the `last_user` to if any.

### cancel_upgrade

Cancels upgrade if it is scheduled, does nothing otherwise.

**Parameters:**

- `force` `ForceID`: The force who did the upgrade order.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to if any.

**Returns:**

- `boolean`: Whether the cancel was successful.

### clear_fluid_inside

Remove all fluids from this entity.

### clear_market_items

Removes all offers from a market.

### clone

Clones this entity.

**Parameters:**

- `create_build_effect_smoke` `boolean` _(optional)_: If false, the building effect smoke will not be shown around the new entity.
- `force` `ForceID` _(optional)_: 
- `position` `MapPosition`: The destination position
- `surface` `LuaSurface` _(optional)_: The destination surface

**Returns:**

- `LuaEntity`: The cloned entity or `nil` if this entity can't be cloned/can't be cloned to the given location.

### connect_linked_belts

Connects current linked belt with another one.

Neighbours have to be of different type. If given linked belt is connected to something else it will be disconnected first. If provided neighbour is connected to something else it will also be disconnected first. Automatically updates neighbour to be connected back to this one.

Can also be used on entity ghost if it contains linked-belt.

**Parameters:**

- `neighbour` `LuaEntity` _(optional)_: Another linked belt or entity ghost containing linked belt to connect or nil to disconnect

### connect_rolling_stock

Connects the rolling stock in the given direction.

**Parameters:**

- `direction` `defines.rail_direction`: 

**Returns:**

- `boolean`: Whether any connection was made

### copy_settings

Copies settings from the given entity onto this entity.

**Parameters:**

- `by_player` `PlayerIdentification` _(optional)_: If provided, the copying is done 'as' this player and [on_entity_settings_pasted](runtime:on_entity_settings_pasted) is triggered.
- `entity` `LuaEntity`: 

**Returns:**

- ``ItemWithQualityCounts`[]`: Any items removed from this entity as a result of copying the settings.

### create_build_effect_smoke

Creates the same smoke that is created when you place a building by hand.

You can play the building sound to go with it by using [LuaSurface::play_sound](runtime:LuaSurface::play_sound), eg: `entity.surface.play_sound{path="entity-build/"..entity.prototype.name, position=entity.position}`

### create_cargo_pod

Creates a cargo pod if possible.

Cargo pod will be created with [invalid](runtime:defines.cargo_destination.invalid) destination type. Setting [cargo_pod_destination](runtime:LuaEntity::cargo_pod_destination) will cause it to launch.

**Parameters:**

- `cargo_hatch` `LuaCargoHatch` _(optional)_: The hatch to create the pod at. A random (available) one is picked if not provided.

**Returns:**

- `LuaEntity`: 

### damage

Damages the entity.

**Parameters:**

- `cause` `LuaEntity` _(optional)_: The entity that originally triggered the events that led to this damage being dealt (e.g. the character, turret, enemy, etc. that pulled the trigger). Does not need to be on the same surface as the entity being damaged.
- `damage` `float`: The amount of damage to be done.
- `force` `ForceID`: The force that will be doing the damage.
- `source` `LuaEntity` _(optional)_: The entity that is directly dealing the damage (e.g. the projectile, flame, sticker, grenade, laser beam, etc.). Needs to be on the same surface as the entity being damaged.
- `type` `DamageTypeID` _(optional)_: The type of damage to be done, defaults to `"impact"`.

**Returns:**

- `float`: the total damage actually applied after resistances.

### deplete

Depletes and destroys this resource entity.

### destroy

Destroys the entity.

Not all entities can be destroyed - things such as rails under trains cannot be destroyed until the train is moved or destroyed.

**Parameters:**

- `do_cliff_correction` `boolean` _(optional)_: Whether neighbouring cliffs should be corrected. Defaults to `false`.
- `item_index` `uint` _(optional)_: The index of the undo item to add this action to. An index of `0` creates a new undo item for it. Defaults to putting it into the appropriate undo item automatically if not specified.
- `player` `PlayerIdentification` _(optional)_: The player whose undo queue this action should be added to.
- `raise_destroy` `boolean` _(optional)_: If `true`, [script_raised_destroy](runtime:script_raised_destroy) will be called. Defaults to `false`.

**Returns:**

- `boolean`: Returns `false` if the entity was valid and destruction failed, `true` in all other cases.

### die

Immediately kills the entity. Does nothing if the entity doesn't have health.

Unlike [LuaEntity::destroy](runtime:LuaEntity::destroy), `die` will trigger the [on_entity_died](runtime:on_entity_died) event and the entity will produce a corpse and drop loot if it has any.

**Parameters:**

- `cause` `LuaEntity` _(optional)_: The cause to attribute the kill to.
- `force` `ForceID` _(optional)_: The force to attribute the kill to.

**Returns:**

- `boolean`: Whether the entity was successfully killed.

### disconnect_linked_belts

Disconnects linked belt from its neighbour.

Can also be used on entity ghost if it contains linked-belt

### disconnect_rolling_stock

Tries to disconnect this rolling stock in the given direction.

**Parameters:**

- `direction` `defines.rail_direction`: 

**Returns:**

- `boolean`: If anything was disconnected

### force_finish_ascending

Take an ascending cargo pod and safely make it skip all animation and immediately switch surface.

### force_finish_descending

Take a descending cargo pod and safely make it arrive and deposit cargo.

### get_beacon_effect_receivers

Returns a table with all entities affected by this beacon

**Returns:**

- ``LuaEntity`[]`: 

### get_beacons

Returns a table with all beacons affecting this effect receiver. Can only be used when the entity has an effect receiver (AssemblingMachine, Furnace, Lab, MiningDrills)

**Returns:**

- ``LuaEntity`[]`: 

### get_beam_source

Get the source of this beam.

**Returns:**

- `BeamTarget`: 

### get_beam_target

Get the target of this beam.

**Returns:**

- `BeamTarget`: 

### get_burnt_result_inventory

The burnt result inventory for this entity or `nil` if this entity doesn't have a burnt result inventory.

**Returns:**

- `LuaInventory`: 

### get_cargo_bays

Gets the cargo bays connected to this cargo landing pad or space platform hub.

**Returns:**

- ``LuaEntity`[]`: 

### get_child_signals

Returns all child signals. Child signals can be either RailSignal or RailChainSignal. Child signals are signals which are checked by this signal to determine a chain state.

**Returns:**

- ``LuaEntity`[]`: 

### get_circuit_network



**Parameters:**

- `wire_connector_id` `defines.wire_connector_id`: Wire connector to get circuit network for.

**Returns:**

- `LuaCircuitNetwork`: The circuit network or nil.

### get_connected_rail



**Parameters:**

- `rail_connection_direction` `defines.rail_connection_direction`: 
- `rail_direction` `defines.rail_direction`: 

**Returns:**

- `LuaEntity`: Rail connected in the specified manner to this one, `nil` if unsuccessful.
- `defines.rail_direction`: Rail direction of the returned rail which points to origin rail
- `defines.rail_connection_direction`: Turn to be taken when going back from returned rail to origin rail

### get_connected_rails

Get the rails that this signal is connected to.

**Returns:**

- ``LuaEntity`[]`: 

### get_connected_rolling_stock

Gets rolling stock connected to the given end of this stock.

**Parameters:**

- `direction` `defines.rail_direction`: 

**Returns:**

- `LuaEntity`: The rolling stock connected at the given end, `nil` if none is connected there.
- `defines.rail_direction`: The rail direction of the connected rolling stock if any.

### get_control_behavior

Gets the control behavior of the entity (if any).

**Returns:**

- `LuaControlBehavior`: The control behavior or `nil`.

### get_damage_to_be_taken

Returns the amount of damage to be taken by this entity.

**Returns:**

- `float`: `nil` if this entity does not have health.

### get_driver

Gets the driver of this vehicle if any.

**Returns:**

- : `nil` if the vehicle contains no driver. To check if there's a passenger see [LuaEntity::get_passenger](runtime:LuaEntity::get_passenger).

### get_electric_input_flow_limit

The input flow limit for the electric energy source. `nil` if the entity doesn't have an electric energy source.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_electric_output_flow_limit

The output flow limit for the electric energy source. `nil` if the entity doesn't have an electric energy source.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_filter

Get the filter for a slot in an inserter, loader, mining drill, asteroid collector, or logistic storage container. The entity must allow filters.

**Parameters:**

- `slot_index` `uint`: Index of the slot to get the filter for.

**Returns:**

- : The filter, or `nil` if the given slot has no filter.

### get_fluid

Gets fluid of the i-th fluid storage.

**Parameters:**

- `index` `uint`: Fluid storage index. Valid values are from 1 up to [LuaEntity::fluids_count](runtime:LuaEntity::fluids_count).

**Returns:**

- `Fluid`: Fluid in this storage. nil if fluid storage is empty.

### get_fluid_contents

Get amounts of all fluids in this entity.

If information about fluid temperatures is required, [LuaEntity::fluidbox](runtime:LuaEntity::fluidbox) should be used instead.

**Returns:**

- `dictionary<`string`, `double`>`: The amounts, indexed by fluid names.

### get_fluid_count

Get the amount of all or some fluid in this entity.

If information about fluid temperatures is required, [LuaEntity::fluidbox](runtime:LuaEntity::fluidbox) should be used instead.

**Parameters:**

- `fluid` `string` _(optional)_: Prototype name of the fluid to count. If not specified, count all fluids.

**Returns:**

- `double`: 

### get_fluid_source_fluid

Checks what is expected fluid to be produced from the offshore pump's source tile. It accounts for visible tile, hidden tile and double hidden tile. It ignores currently set fluid box filter.

**Returns:**

- `string`: Name of fluid that should be produced by this offshore pump based on existing tiles.

### get_fluid_source_tile

Gives TilePosition of a tile which this offshore pump uses to check what fluid should be produced.

**Returns:**

- `TilePosition`: 

### get_fuel_inventory

The fuel inventory for this entity or `nil` if this entity doesn't have a fuel inventory.

**Returns:**

- `LuaInventory`: 

### get_health_ratio

The health ratio of this entity between 1 and 0 (for full health and no health respectively).

**Returns:**

- `float`: `nil` if this entity doesn't have health.

### get_heat_setting

Gets the heat setting for this heat interface.

**Returns:**

- `HeatSetting`: 

### get_inbound_signals

Returns all signals guarding entrance to a rail block this rail belongs to.

**Returns:**

- ``LuaEntity`[]`: 

### get_infinity_container_filter

Gets the filter for this infinity container at the given index, or `nil` if the filter index doesn't exist or is empty.

**Parameters:**

- `index` `uint`: The index to get.

**Returns:**

- `InfinityInventoryFilter`: 

### get_infinity_pipe_filter

Gets the filter for this infinity pipe, or `nil` if the filter is empty.

**Returns:**

- `InfinityPipeFilter`: 

### get_inventory_size_override

Gets the inventory size override of the selected inventory if size override was set using [set_inventory_size_override](runtime:LuaEntity::set_inventory_size_override).

**Parameters:**

- `inventory_index` `defines.inventory`: 

**Returns:**

- `uint16`: 

### get_item_insert_specification

Get an item insert specification onto a belt connectable: for a given map position provides into which line at what position item should be inserted to be closest to the provided position.

**Parameters:**

- `position` `MapPosition`: Position where the item is to be inserted.

**Returns:**

- `uint`: Index of the transport line that is closest to the provided map position.
- `float`: Position along the transport line where item should be dropped.

### get_line_item_position

Get a map position related to a position on a transport line.

**Parameters:**

- `index` `uint`: Index of the transport line. Transport lines are 1-indexed.
- `position` `float`: Linear position along the transport line. Clamped to the transport line range.

**Returns:**

- `MapPosition`: 

### get_logistic_point

Gets all the `LuaLogisticPoint`s that this entity owns. Optionally returns only the point specified by the index parameter.

**Parameters:**

- `index` `defines.logistic_member_index` _(optional)_: If provided, this method only returns the `LuaLogisticPoint` specified by this index, or `nil` if it doesn't exist.

**Returns:**

- : 

### get_logistic_sections

Gives logistic sections of this entity if it uses logistic sections.

**Returns:**

- `LuaLogisticSections`: 

### get_market_items

Get all offers in a market as an array.

**Returns:**

- ``Offer`[]`: 

### get_max_transport_line_index

Get the maximum transport line index of a belt or belt connectable entity.

**Returns:**

- `uint`: 

### get_module_inventory

Inventory for storing modules of this entity; `nil` if this entity has no module inventory.

**Returns:**

- `LuaInventory`: 

### get_or_create_control_behavior

Gets (and or creates if needed) the control behavior of the entity.

**Returns:**

- `LuaControlBehavior`: The control behavior or `nil`.

### get_outbound_signals

Returns all signals guarding exit from a rail block this rail belongs to.

**Returns:**

- ``LuaEntity`[]`: 

### get_output_inventory

Gets the entity's output inventory if it has one.

**Returns:**

- `LuaInventory`: A reference to the entity's output inventory.

### get_parent_signals

Returns all parent signals. Parent signals are always RailChainSignal. Parent signals are those signals that are checking state of this signal to determine their own chain state.

**Returns:**

- ``LuaEntity`[]`: 

### get_passenger

Gets the passenger of this car, spidertron, or cargo pod if any.

This differs over [LuaEntity::get_driver](runtime:LuaEntity::get_driver) in that for cars, the passenger can't drive the car.

**Returns:**

- : `nil` if the vehicle contains no passenger. To check if there's a driver see [LuaEntity::get_driver](runtime:LuaEntity::get_driver).

### get_priority_target

Get the entity ID at the specified position in the turret's priority list.

**Parameters:**

- `index` `uint`: The index of the entry to fetch.

**Returns:**

- `LuaEntityPrototype`: 

### get_radius

The radius of this entity.

**Returns:**

- `double`: 

### get_rail_end

Gets a LuaRailEnd object for specified end of this rail

**Parameters:**

- `direction` `defines.rail_direction`: 

**Returns:**

- `LuaRailEnd`: 

### get_rail_segment_end

Get the rail at the end of the rail segment this rail is in.

A rail segment is a continuous section of rail with no branches, signals, nor train stops.

**Parameters:**

- `direction` `defines.rail_direction`: 

**Returns:**

- `LuaEntity`: The rail entity.
- `defines.rail_direction`: A rail direction pointing out of the rail segment from the end rail.

### get_rail_segment_length

Get the length of the rail segment this rail is in.

A rail segment is a continuous section of rail with no branches, signals, nor train stops.

**Returns:**

- `double`: 

### get_rail_segment_overlaps

Get a rail from each rail segment that overlaps with this rail's rail segment.

A rail segment is a continuous section of rail with no branches, signals, nor train stops.

**Returns:**

- ``LuaEntity`[]`: 

### get_rail_segment_rails

Get all rails of a rail segment this rail is in

A rail segment is a continuous section of rail with no branches, signals, nor train stops.

**Parameters:**

- `direction` `defines.rail_direction`: Selects end of this rail that points to a rail segment end from which to start returning rails

**Returns:**

- ``LuaEntity`[]`: Rails of this rail segment

### get_rail_segment_signal

Get the rail signal at the start/end of the rail segment this rail is in.

A rail segment is a continuous section of rail with no branches, signals, nor train stops.

**Parameters:**

- `direction` `defines.rail_direction`: The direction of travel relative to this rail.
- `in_else_out` `boolean`: If true, gets the signal at the entrance of the rail segment, otherwise gets the signal at the exit of the rail segment.

**Returns:**

- `LuaEntity`: `nil` if the rail segment doesn't start/end with a signal.

### get_rail_segment_stop

Get train stop at the start/end of the rail segment this rail is in.

A rail segment is a continuous section of rail with no branches, signals, nor train stops.

**Parameters:**

- `direction` `defines.rail_direction`: The direction of travel relative to this rail.

**Returns:**

- `LuaEntity`: `nil` if the rail segment doesn't start/end with a train stop.

### get_recipe

Current recipe being assembled by this machine, if any.

**Returns:**

- `LuaRecipe`: 
- `LuaQualityPrototype`: 

### get_signal

Read a single signal from the selected wire connector

**Parameters:**

- `extra_wire_connector_id` `defines.wire_connector_id` _(optional)_: Additional wire connector ID. If specified, signal will be added to the result
- `signal` `SignalID`: The signal to read.
- `wire_connector_id` `defines.wire_connector_id`: Wire connector ID from which to get the signal

**Returns:**

- `int`: The current value of the signal.

### get_signals

Read all signals from the selected wire connector.

**Parameters:**

- `extra_wire_connector_id` `defines.wire_connector_id` _(optional)_: Additional wire connector ID. If specified, signals will be added to the result
- `wire_connector_id` `defines.wire_connector_id`: Wire connector ID from which to get the signal

**Returns:**

- ``Signal`[]`: Current values of all signals.

### get_spider_legs

Gets legs of given SpiderVehicle.

**Returns:**

- ``LuaEntity`[]`: 

### get_stopped_train

The train currently stopped at this train stop, if any.

**Returns:**

- `LuaTrain`: 

### get_train_stop_trains

The trains scheduled to stop at this train stop.

**Returns:**

- ``LuaTrain`[]`: 

### get_transport_line

Get a transport line of a belt or belt connectable entity.

**Parameters:**

- `index` `uint`: Index of the requested transport line. Transport lines are 1-indexed.

**Returns:**

- `LuaTransportLine`: 

### get_upgrade_target

Returns the new entity prototype and its quality.

**Returns:**

- `LuaEntityPrototype`: `nil` if this entity is not marked for upgrade.
- `LuaQualityPrototype`: `nil` if this entity is not marked for upgrade.

### get_wire_connector

Gets a single wire connector of this entity

**Parameters:**

- `or_create` `boolean`: If true and connector does not exist, it will be allocated if possible
- `wire_connector_id` `defines.wire_connector_id`: Identifier of a specific connector to get

**Returns:**

- `LuaWireConnector`: 

### get_wire_connectors

Gets all wire connectors of this entity

**Parameters:**

- `or_create` `boolean`: If true, it will try to create all connectors possible

**Returns:**

- `dictionary<`defines.wire_connector_id`, `LuaWireConnector`>`: 

### ghost_has_flag

Same as [LuaEntity::has_flag](runtime:LuaEntity::has_flag), but targets the inner entity on a entity ghost.

**Parameters:**

- `flag` `EntityPrototypeFlag`: The flag to test.

**Returns:**

- `boolean`: `true` if the entity has the given flag set.

### has_flag

Test whether this entity's prototype has a certain flag set.

`entity.has_flag(f)` is a shortcut for `entity.prototype.has_flag(f)`.

**Parameters:**

- `flag` `EntityPrototypeFlag`: The flag to test.

**Returns:**

- `boolean`: `true` if this entity has the given flag set.

### insert_fluid

Insert fluid into this entity. Fluidbox is chosen automatically.

**Parameters:**

- `fluid` `Fluid`: Fluid to insert.

**Returns:**

- `double`: Amount of fluid actually inserted.

### is_closed



**Returns:**

- `boolean`: `true` if this gate is currently closed.

### is_closing



**Returns:**

- `boolean`: `true` if this gate is currently closing

### is_connected_to_electric_network

Returns `true` if this entity produces or consumes electricity and is connected to an electric network that has at least one entity that can produce power.

**Returns:**

- `boolean`: 

### is_crafting

Returns whether a craft is currently in process. It does not indicate whether progress is currently being made, but whether a crafting process has been started in this machine.

**Returns:**

- `boolean`: 

### is_opened



**Returns:**

- `boolean`: `true` if this gate is currently opened.

### is_opening



**Returns:**

- `boolean`: `true` if this gate is currently opening.

### is_rail_in_same_rail_block_as

Checks if this rail and other rail both belong to the same rail block.

**Parameters:**

- `other_rail` `LuaEntity`: 

**Returns:**

- `boolean`: 

### is_rail_in_same_rail_segment_as

Checks if this rail and other rail both belong to the same rail segment.

**Parameters:**

- `other_rail` `LuaEntity`: 

**Returns:**

- `boolean`: 

### is_registered_for_construction

Is this entity or tile ghost or item request proxy registered for construction? If false, it means a construction robot has been dispatched to build the entity, or it is not an entity that can be constructed.

**Returns:**

- `boolean`: 

### is_registered_for_deconstruction

Is this entity registered for deconstruction with this force? If false, it means a construction robot has been dispatched to deconstruct it, or it is not marked for deconstruction. The complexity is effectively O(1) - it depends on the number of objects targeting this entity which should be small enough.

**Parameters:**

- `force` `ForceID`: The force construction manager to check.

**Returns:**

- `boolean`: 

### is_registered_for_repair

Is this entity registered for repair? If false, it means a construction robot has been dispatched to repair it, or it is not damaged. This is worst-case O(N) complexity where N is the current number of things in the repair queue.

**Returns:**

- `boolean`: 

### is_registered_for_upgrade

Is this entity registered for upgrade? If false, it means a construction robot has been dispatched to upgrade it, or it is not marked for upgrade. This is worst-case O(N) complexity where N is the current number of things in the upgrade queue.

**Returns:**

- `boolean`: 

### launch_rocket



**Parameters:**

- `character` `LuaEntity` _(optional)_: If provided, must be of `character` type.
- `destination` `CargoDestination` _(optional)_: 

**Returns:**

- `boolean`: `true` if the rocket was successfully launched. Return value of `false` means the silo is not ready for launch.

### mine

Mines this entity.

'Standard' operation is to keep calling `LuaEntity.mine` with an inventory until all items are transferred and the items dealt with.

The result of mining the entity (the item(s) it produces when mined) will be dropped on the ground if they don't fit into the provided inventory. If no inventory is provided, the items will be destroyed.

**Parameters:**

- `force` `boolean` _(optional)_: If true, when the item(s) don't fit into the given inventory the entity is force mined. If false, the mining operation fails when there isn't enough room to transfer all of the items into the inventory. Defaults to false. This is ignored and acts as `true` if no inventory is provided.
- `ignore_minable` `boolean` _(optional)_: If true, the minable state of the entity is ignored. Defaults to `false`. If false, an entity that isn't minable (set as not-minable in the prototype or isn't minable for other reasons) will fail to be mined.
- `inventory` `LuaInventory` _(optional)_: If provided the item(s) will be transferred into this inventory. If provided, this must be an inventory created with [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory) or be a basic inventory owned by some entity.
- `raise_destroyed` `boolean` _(optional)_: If true, [script_raised_destroy](runtime:script_raised_destroy) will be raised. Defaults to `true`.

**Returns:**

- `boolean`: Whether mining succeeded.

### order_deconstruction

Sets the entity to be deconstructed by construction robots.

**Parameters:**

- `force` `ForceID`: The force whose robots are supposed to do the deconstruction.
- `item_index` `uint` _(optional)_: The index of the undo item to add this action to. An index of `0` creates a new undo item for it. An index of `1` adds the action to the latest undo action on the stack. Defaults to putting it into the appropriate undo item automatically if one is not specified.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to, if any. Also the player whose undo queue this action should be added to.

**Returns:**

- `boolean`: if the entity was marked for deconstruction.

### order_upgrade

Sets the entity to be upgraded by construction robots.

**Parameters:**

- `force` `ForceID`: The force whose robots are supposed to do the upgrade.
- `item_index` `uint` _(optional)_: The index of the undo item to add this action to. An index of `0` creates a new undo item for it. Defaults to putting it into the appropriate undo item automatically if not specified.
- `player` `PlayerIdentification` _(optional)_: The player whose undo queue this action should be added to.
- `target` `EntityWithQualityID`: The prototype of the entity to upgrade to.

**Returns:**

- `boolean`: Whether the entity was marked for upgrade.

### play_note

Plays a note with the given instrument and note.

**Parameters:**

- `instrument` `uint`: 
- `note` `uint`: 
- `stop_playing_sounds` `boolean` _(optional)_: 

**Returns:**

- `boolean`: Whether the request is valid. The sound may or may not be played depending on polyphony settings.

### release_from_spawner

Release the unit from the spawner which spawned it. This allows the spawner to continue spawning additional units.

### remove_fluid

Remove fluid from this entity.

If temperature is given only fluid matching that exact temperature is removed. If minimum and maximum is given fluid within that range is removed.

**Parameters:**

- `amount` `double`: Amount to remove
- `maximum_temperature` `double` _(optional)_: 
- `minimum_temperature` `double` _(optional)_: 
- `name` `string`: Fluid prototype name.
- `temperature` `double` _(optional)_: 

**Returns:**

- `double`: Amount of fluid actually removed.

### remove_market_item

Remove an offer from a market.

The other offers are moved down to fill the gap created by removing the offer, which decrements the overall size of the offer array.

**Parameters:**

- `offer` `uint`: Index of offer to remove.

**Returns:**

- `boolean`: `true` if the offer was successfully removed; `false` when the given index was not valid.

### request_to_close



**Parameters:**

- `force` `ForceID`: The force that requests the gate to be closed.

### request_to_open



**Parameters:**

- `extra_time` `uint` _(optional)_: Extra ticks to stay open.
- `force` `ForceID`: The force that requests the gate to be open.

### revive

Revive a ghost, which turns it from a ghost into a real entity or tile.

**Parameters:**

- `raise_revive` `boolean` _(optional)_: If true, and an entity ghost; [script_raised_revive](runtime:script_raised_revive) will be called. Else if true, and a tile ghost; [script_raised_set_tiles](runtime:script_raised_set_tiles) will be called.
- `return_item_request_proxy` `boolean` _(optional)_: If `true` the function will return item request proxy as the third return value.

**Returns:**

- `dictionary<`string`, `uint`>`: Any items the new real entity collided with or `nil` if the ghost could not be revived.
- `LuaEntity`: The revived entity if an entity ghost was successfully revived.
- `LuaEntity`: The item request proxy if it was requested with `return_item_request_proxy`.

### rotate

Rotates this entity as if the player rotated it.

**Parameters:**

- `by_player` `PlayerIdentification` _(optional)_: 
- `reverse` `boolean` _(optional)_: If `true`, rotate the entity in the counter-clockwise direction.

**Returns:**

- `boolean`: Whether the rotation was successful.

### set_beam_source

Set the source of this beam.

**Parameters:**

- `source` : 

### set_beam_target

Set the target of this beam.

**Parameters:**

- `target` : 

### set_driver

Sets the driver of this vehicle.

This differs from [LuaEntity::set_passenger](runtime:LuaEntity::set_passenger) in that the passenger can't drive the vehicle.

**Parameters:**

- `driver`  _(optional)_: The new driver. Writing `nil` ejects the current driver, if any.

### set_filter

Set the filter for a slot in an inserter (ItemFilter), loader (ItemFilter), mining drill (EntityID), asteroid collector (AsteroidChunkID) or logistic storage container (ItemWithQualityID). The entity must allow filters.

**Parameters:**

- `filter`  _(optional)_: The item or entity to filter, or `nil` to clear the filter.
- `index` `uint`: Index of the slot to set the filter for.

### set_fluid

Sets fluid to the i-th fluid storage.

Fluid storages that are part of FluidBoxes (also available through [LuaFluidBox](runtime:LuaFluidBox)) may reject some fluids if they do not match filters or are above the FluidBox volume. To verify how much fluid was set a return value can be used which is the same as value that would be returned by [LuaEntity::get_fluid](runtime:LuaEntity::get_fluid).

**Parameters:**

- `fluid` `Fluid` _(optional)_: Fluid to set. Fluid storage will be cleared if this is not provided.
- `index` `uint`: Fluid storage index. Valid values are from 1 up to [LuaEntity::fluids_count](runtime:LuaEntity::fluids_count).

**Returns:**

- `Fluid`: Fluid in this storage after it was set. nil if fluid storage is empty.

### set_heat_setting

Sets the heat setting for this heat interface.

**Parameters:**

- `filter` `HeatSetting`: The new setting.

### set_infinity_container_filter

Sets the filter for this infinity container at the given index.

**Parameters:**

- `filter` : The new filter, or `nil` to clear the filter.
- `index` `uint`: The index to set.

### set_infinity_pipe_filter

Sets the filter for this infinity pipe.

**Parameters:**

- `filter` : The new filter, or `nil` to clear the filter.

### set_inventory_size_override

Sets inventory size override. When set, supported entity will ignore inventory size from prototype and will instead keep inventory size equal to the override. Setting `nil` will restore default inventory size.

**Parameters:**

- `inventory_index` `defines.inventory`: 
- `overflow` `LuaInventory` _(optional)_: Items that would be deleted due to change of inventory size will be transferred to this inventory. Must be a script inventory or inventory of other entity. Inventory references obtained from proxy container are not allowed.
- `size_override` : 

### set_passenger

Sets the passenger of this car, spidertron, or cargo pod.

This differs from [LuaEntity::get_driver](runtime:LuaEntity::get_driver) in that the passenger can't drive the car.

**Parameters:**

- `passenger`  _(optional)_: The new passenger. Writing `nil` ejects the current passenger, if any.

### set_priority_target

Set the entity ID name at the specified position in the turret's priority list.

**Parameters:**

- `entity_id` `EntityID` _(optional)_: The name of the entity prototype, or `nil` to clear the entry.
- `index` `uint`: The index of the entry to set.

### set_recipe

Sets the given recipe in this assembly machine.

**Parameters:**

- `quality` `QualityID` _(optional)_: The quality. If not provided `normal` is used.
- `recipe` `RecipeID` _(optional)_: The new recipe. Writing `nil` clears the recipe, if any.

**Returns:**

- ``ItemWithQualityCounts`[]`: Any items removed from this entity as a result of setting the recipe.

### silent_revive

Revives a ghost silently, so the revival makes no sound and no smoke is created.

**Parameters:**

- `raise_revive` `boolean` _(optional)_: If true, and an entity ghost; [script_raised_revive](runtime:script_raised_revive) will be called. Else if true, and a tile ghost; [script_raised_set_tiles](runtime:script_raised_set_tiles) will be called.

**Returns:**

- ``ItemWithQualityCounts`[]`: Any items the new real entity collided with or `nil` if the ghost could not be revived.
- `LuaEntity`: The revived entity if an entity ghost was successfully revived.
- `LuaEntity`: The item request proxy.

### spawn_decorations

Triggers spawn_decoration actions defined in the entity prototype or does nothing if entity is not "turret" or "unit-spawner".

### start_fading_out

Only works if the entity is a speech-bubble, with an "effect" defined in its wrapper_flow_style. Starts animating the opacity of the speech bubble towards zero, and destroys the entity when it hits zero.

### stop_spider

Sets the [speed](runtime:LuaEntity::speed) of the given SpiderVehicle to zero. Notably does not clear its [autopilot_destination](runtime:LuaEntity::autopilot_destination), which it will continue moving towards if set.

### supports_backer_name

Whether this entity supports a backer name.

**Returns:**

- `boolean`: 

### to_be_deconstructed

Is this entity marked for deconstruction?

**Returns:**

- `boolean`: 

### to_be_upgraded

Is this entity marked for upgrade?

**Returns:**

- `boolean`: 

### toggle_equipment_movement_bonus

Toggle this entity's equipment movement bonus. Does nothing if the entity does not have an equipment grid.

This property can also be read and written on the equipment grid of this entity.

### update_connections

Reconnect loader, beacon, cliff and mining drill connections to entities that might have been teleported out or in by the script. The game doesn't do this automatically as we don't want to lose performance by checking this in normal games.

## Attributes

### absorbed_pollution

**Type:** `double` _(read-only)_



### active

**Type:** `boolean`

Deactivating an entity will stop all its operations (car will stop moving, inserters will stop working, fish will stop moving etc).

Entities that are not active naturally can't be set to be active (setting it to be active will do nothing)

Ghosts, simple smoke, and corpses can't be modified at this time.

It is even possible to set the character to not be active, so he can't move and perform most of the tasks.

### ai_settings

**Type:** `LuaAISettings` _(read-only)_

The ai settings of this unit.

### alert_parameters

**Type:** `ProgrammableSpeakerAlertParameters`



### allow_dispatching_robots

**Type:** `boolean`

Whether this character's personal roboports are allowed to dispatch robots.

### always_on

**Type:** `boolean`

If the lamp is always on when not driven by control behavior.

### amount

**Type:** `uint`

Count of resource units contained.

### armed

**Type:** `boolean` _(read-only)_

Whether this land mine is armed.

### artillery_auto_targeting

**Type:** `boolean`

If this artillery auto-targets enemies.

### associated_player

**Type:** `LuaPlayer`

The player this character is associated with, if any. Set to `nil` to clear.

The player will be automatically disassociated when a controller is set on the character. Also, all characters associated to a player will be logged off when the player logs off in multiplayer.

A character associated with a player is not directly controlled by any player.

### attached_cargo_pod

**Type:** `LuaEntity` _(read-only)_

The cargo pod attached to this rocket silo rocket if any.

### autopilot_destination

**Type:** `MapPosition`

Destination of this spidertron's autopilot, if any. Writing `nil` clears all destinations.

### autopilot_destinations

**Type:** ``MapPosition`[]` _(read-only)_

The queued destination positions of spidertron's autopilot.

### backer_name

**Type:** `string`

The backer name assigned to this entity. Entities that support backer names are labs, locomotives, radars, roboports, and train stops. `nil` if this entity doesn't support backer names.

While train stops get the name of a backer when placed down, players can rename them if they want to. In this case, `backer_name` returns the player-given name of the entity.

### base_damage_modifiers

**Type:** `TriggerModifierData`



### beacons_count

**Type:** `uint` _(read-only)_

Number of beacons affecting this effect receiver. Can only be used when the entity has an effect receiver (AssemblingMachine, Furnace, Lab, MiningDrills)

### belt_neighbours

**Type:** `unknown` _(read-only)_

The belt connectable neighbours of this belt connectable entity. Only entities that input to or are outputs of this entity. Does not contain the other end of an underground belt, see [LuaEntity::neighbours](runtime:LuaEntity::neighbours) for that.

### belt_shape

**Type:**  _(read-only)_

Gives what is the current shape of a transport-belt.

Can also be used on entity ghost if it contains transport-belt.

### belt_to_ground_type

**Type:**  _(read-only)_

Whether this underground belt goes into or out of the ground.

### bonus_damage_modifiers

**Type:** `TriggerModifierData`



### bonus_mining_progress

**Type:** `double`

The bonus mining progress for this mining drill. Read yields a number in range [0, mining_target.prototype.mineable_properties.mining_time]. `nil` if this isn't a mining drill.

### bonus_progress

**Type:** `double`

The current productivity bonus progress, as a number in range `[0, 1]`.

### bounding_box

**Type:** `BoundingBox` _(read-only)_

[LuaEntityPrototype::collision_box](runtime:LuaEntityPrototype::collision_box) around entity's given position and respecting the current entity orientation.

### burner

**Type:** `LuaBurner` _(read-only)_

The burner energy source for this entity, if any.

### cargo_bay_connection_owner

**Type:** `LuaEntity` _(read-only)_

The space platform hub or cargo landing pad this cargo bay is connected to if any.

### cargo_hatches

**Type:** ``LuaCargoHatch`[]` _(read-only)_

The cargo hatches owned by this entity if any.

### cargo_pod_destination

**Type:** `CargoDestination`

The destination of this cargo pod entity.

Use [force_finish_ascending](runtime:LuaEntity::force_finish_ascending) if you want it to only descend from orbit.

### cargo_pod_origin

**Type:** `LuaEntity`

The origin of this cargo pod entity. (Must be a silo, hub or pad)

### cargo_pod_state

**Type:**  _(read-only)_

The state of this cargo pod entity.

### chain_signal_state

**Type:** `defines.chain_signal_state` _(read-only)_

The state of this chain signal.

### character_corpse_death_cause

**Type:** `LocalisedString`

The reason this character corpse character died. `""` if there is no reason.

### character_corpse_player_index

**Type:** `uint`

The player index associated with this character corpse.

The index is not guaranteed to be valid so it should always be checked first if a player with that index actually exists.

### character_corpse_tick_of_death

**Type:** `uint`

The tick this character corpse died at.

### cliff_orientation

**Type:** `CliffOrientation` _(read-only)_

The orientation of this cliff.

### color

**Type:** `Color`

The color of this character, rolling stock, train stop, car, spider-vehicle, flying text, corpse or simple-entity-with-owner. `nil` if this entity doesn't use custom colors.

Car color is overridden by the color of the current driver/passenger, if there is one.

### combat_robot_owner

**Type:** `LuaEntity`

The owner of this combat robot, if any.

### combinator_description

**Type:** `string`

The description on this combinator.

### commandable

**Type:** `LuaCommandable` _(read-only)_

Returns a LuaCommandable for this entity or nil if entity is not commandable.

### connected_rail

**Type:** `LuaEntity` _(read-only)_

The rail entity this train stop is connected to, if any.

### connected_rail_direction

**Type:** `defines.rail_direction` _(read-only)_

Rail direction to which this train stop is binding. This returns a value even when no rails are present.

### consumption_bonus

**Type:** `double` _(read-only)_

The consumption bonus of this entity.

### consumption_modifier

**Type:** `float`

Multiplies the energy consumption.

### copy_color_from_train_stop

**Type:** `boolean`

If this RollingStock has 'copy color from train stop' enabled.

### corpse_expires

**Type:** `boolean`

Whether this corpse will ever fade away.

### corpse_immune_to_entity_placement

**Type:** `boolean`

If true, corpse won't be destroyed when entities are placed over it. If false, whether corpse will be removed or not depends on value of [CorpsePrototype::remove_on_entity_placement](prototype:CorpsePrototype::remove_on_entity_placement).

### crafting_progress

**Type:** `float`

The current crafting progress, as a number in range `[0, 1]`.

### crafting_speed

**Type:** `double` _(read-only)_

The current crafting speed, including speed bonuses from modules and beacons.

### crane_destination

**Type:** `MapPosition`

Destination of the crane of this entity. Throws when trying to set the destination out of range.

### crane_destination_3d

**Type:** `Vector3D`

Destination of the crane of this entity in 3D. Throws when trying to set the destination out of range.

### crane_end_position_3d

**Type:** `Vector3D` _(read-only)_

Returns current position in 3D for the end of the crane of this entity.

### crane_grappler_destination

**Type:** `any`

Will set destination for the grappler of crane of this entity. The crane grappler will start moving to reach the destination, but the rest of the arm will remain stationary. Throws when trying to set the destination out of range.

### crane_grappler_destination_3d

**Type:** `any`

Will set destination in 3D for the grappler of crane of this entity. The crane grappler will start moving to reach the destination, but the rest of the arm will remain stationary. Throws when trying to set the destination out of range.

### custom_status

**Type:** `CustomEntityStatus`

A custom status for this entity that will be displayed in the GUI.

### damage_dealt

**Type:** `double`

The damage dealt by this turret, artillery turret, or artillery wagon.

### destructible

**Type:** `boolean`

If set to `false`, this entity can't be damaged and won't be attacked automatically. It can however still be mined.

Entities that are indestructible naturally (they have no health, like smoke, resource etc) can't be set to be destructible.

### direction

**Type:** `defines.direction`

The current direction this entity is facing.

### disabled_by_control_behavior

**Type:** `boolean` _(read-only)_

If the updatable entity is disabled by control behavior.

### disabled_by_recipe

**Type:** `boolean` _(read-only)_

If the updatable entity is disabled by recipe.

### disabled_by_script

**Type:** `boolean`

If the updatable entity is disabled by script.

Note: Some entities (Corpse, FireFlame, Roboport, RollingStock, dying entities) need to remain active and will ignore writes.

### draw_data

**Type:** `RollingStockDrawData` _(read-only)_

Gives a draw data of the given entity if it supports such data.

### driver_is_gunner

**Type:** `boolean`

Whether the driver of this car or spidertron is the gunner. If `false`, the passenger is the gunner. `nil` if this is neither a car or a spidertron.

### drop_position

**Type:** `MapPosition`

Position where the entity puts its stuff.

Mining drills and crafting machines can't have their drop position changed; inserters must have `allow_custom_vectors` set to true on their prototype to allow changing the drop position.

Meaningful only for entities that put stuff somewhere, such as mining drills, crafting machines with a drop target or inserters.

### drop_target

**Type:** `LuaEntity`

The entity this entity is putting its items to. If there are multiple possible entities at the drop-off point, writing to this attribute allows a mod to choose which one to drop off items to. The entity needs to collide with the tile box under the drop-off position. `nil` if there is no entity to put items to, or if this is not an entity that puts items somewhere.

### effective_speed

**Type:** `float` _(read-only)_

The current speed of this unit in tiles per tick, taking into account any walking speed modifier given by the tile the unit is standing on. `nil` if this is not a unit.

### effectivity_modifier

**Type:** `float`

Multiplies the acceleration the vehicle can create for one unit of energy. Defaults to `1`.

### effects

**Type:** `ModuleEffects` _(read-only)_

The effects being applied to this entity, if any. For beacons, this is the effect the beacon is broadcasting.

### electric_buffer_size

**Type:** `double`

The buffer size for the electric energy source. `nil` if the entity doesn't have an electric energy source.

Write access is limited to the ElectricEnergyInterface type.

### electric_drain

**Type:** `double` _(read-only)_

The electric drain for the electric energy source. `nil` if the entity doesn't have an electric energy source.

### electric_emissions_per_joule

**Type:** `dictionary<`string`, `double`>` _(read-only)_

The table of emissions of this energy source in `pollution/Joule`, indexed by pollutant type. `nil` if the entity doesn't have an electric energy source. Multiplying values in the returned table by energy consumption in `Watt` gives `pollution/second`.

### electric_network_id

**Type:** `uint` _(read-only)_

Returns the id of the electric network that this entity is connected to, if any.

### electric_network_statistics

**Type:** `LuaFlowStatistics` _(read-only)_

The electric network statistics for this electric pole.

### enable_logistics_while_moving

**Type:** `boolean`

Whether equipment grid logistics are enabled while this vehicle is moving.

### energy

**Type:** `double`

Energy stored in the entity's energy buffer (energy stored in electrical devices etc.). Always 0 for entities that don't have the concept of energy stored inside.

### energy_generated_last_tick

**Type:** `double` _(read-only)_

How much energy this generator generated in the last tick.

### entity_label

**Type:** `string`

The label on this spider-vehicle entity, if any. `nil` if this is not a spider-vehicle.

### filter_slot_count

**Type:** `uint` _(read-only)_

The number of filter slots this inserter, loader, mining drill, asteroid collector or logistic storage container has. 0 if not one of those entities.

### fluidbox

**Type:** `LuaFluidBox` _(read-only)_

Fluidboxes of this entity.

### fluids_count

**Type:** `uint` _(read-only)_

Returns count of fluid storages. This includes fluid storages provided by FluidBoxes but also covers other fluid storages like FluidTurret's internal buffer and FluidWagon's fluid since they are not FluidBox and cannot be exposed through [LuaFluidBox](runtime:LuaFluidBox).

### follow_offset

**Type:** `Vector`

The follow offset of this spidertron, if any entity is being followed. This is randomized each time the follow entity is set.

### follow_target

**Type:** `LuaEntity`

The follow target of this spidertron, if any.

### friction_modifier

**Type:** `float`

Multiplies the car friction rate.

### frozen

**Type:** `boolean` _(read-only)_

If the freezable entity is currently frozen.

### ghost_localised_description

**Type:** `LocalisedString` _(read-only)_



### ghost_localised_name

**Type:** `LocalisedString` _(read-only)_

Localised name of the entity or tile contained in this ghost.

### ghost_name

**Type:** `string` _(read-only)_

Name of the entity or tile contained in this ghost

### ghost_prototype

**Type:**  _(read-only)_

The prototype of the entity or tile contained in this ghost.

### ghost_type

**Type:** `string` _(read-only)_

The prototype type of the entity or tile contained in this ghost.

### ghost_unit_number

**Type:** `uint64` _(read-only)_

The [unit_number](runtime:LuaEntity::unit_number) of the entity contained in this ghost. It is the same as the unit number of the [EntityWithOwnerPrototype](prototype:EntityWithOwnerPrototype) that was destroyed to create this ghost. If it was created by other means, or if the inner entity does not support unit numbers, this property is `nil`.

### gps_tag

**Type:** `string` _(read-only)_

Returns a [rich text](https://wiki.factorio.com/Rich_text) string containing this entity's position and surface name as a gps tag. [Printing](runtime:LuaGameScript::print) it will ping the location of the entity.

### graphics_variation

**Type:** `uint8`

The graphics variation for this entity. `nil` if this entity doesn't use graphics variations.

### grid

**Type:** `LuaEquipmentGrid` _(read-only)_

This entity's equipment grid, if any.

### health

**Type:** `float`

The current health of the entity, if any. Health is automatically clamped to be between `0` and max health (inclusive). Entities with a health of `0` can not be attacked.

To get the maximum possible health of this entity, see [LuaEntity::max_health](runtime:LuaEntity::max_health).

### held_stack

**Type:** `LuaItemStack` _(read-only)_

The item stack currently held in an inserter's hand.

### held_stack_position

**Type:** `MapPosition` _(read-only)_

Current position of the inserter's "hand".

### highlight_box_blink_interval

**Type:** `uint`

The blink interval of this highlight box entity. `0` indicates no blink.

### highlight_box_type

**Type:** `CursorBoxRenderType`

The highlight box type of this highlight box entity.

### ignore_unprioritised_targets

**Type:** `boolean`

Whether this turret shoots at targets that are not on its priority list.

### infinity_container_filters

**Type:** ``InfinityInventoryFilter`[]`

The filters for this infinity container.

### initial_amount

**Type:** `uint`

Count of initial resource units contained. `nil` if this is not an infinite resource.

If this is not an infinite resource, writing will produce an error.

### insert_plan

**Type:** ``BlueprintInsertPlan`[]`

The insert plan for this ghost or item request proxy.

### inserter_filter_mode

**Type:** 

The filter mode for this filter inserter. `nil` if this inserter doesn't use filters.

### inserter_spoil_priority

**Type:** 

The spoil priority for this inserter.

### inserter_stack_size_override

**Type:** `uint`

Sets the stack size limit on this inserter.

Set to `0` to reset.

### inserter_target_pickup_count

**Type:** `uint` _(read-only)_

Returns the current target pickup count of the inserter.

This considers the circuit network, manual override and the inserter stack size limit based on technology.

### is_entity_with_health

**Type:** `boolean` _(read-only)_

If this entity is EntityWithHealth

### is_entity_with_owner

**Type:** `boolean` _(read-only)_

If this entity is EntityWithOwner

### is_freezable

**Type:** `boolean` _(read-only)_

If the entity is freezable.

### is_headed_to_trains_front

**Type:** `boolean` _(read-only)_

If the rolling stock is facing train's front.

### is_military_target

**Type:** `boolean`

Whether this entity is a MilitaryTarget. Can be written to if [LuaEntityPrototype::allow_run_time_change_of_is_military_target](runtime:LuaEntityPrototype::allow_run_time_change_of_is_military_target) returns `true`.

### is_updatable

**Type:** `boolean` _(read-only)_

If the entity is updatable.

### item_request_proxy

**Type:** `LuaEntity` _(read-only)_

The first found item request proxy targeting this entity.

### item_requests

**Type:** ``ItemWithQualityCounts`[]` _(read-only)_

Items this ghost will request when revived or items this item request proxy is requesting.

### kills

**Type:** `uint`

The number of units killed by this turret, artillery turret, or artillery wagon.

### last_user

**Type:** `LuaPlayer`

The last player that changed any setting on this entity. This includes building the entity, changing its color, or configuring its circuit network. `nil` if the last user is not part of the save anymore.

### link_id

**Type:** `uint`

The link ID this linked container is using.

### linked_belt_neighbour

**Type:** `LuaEntity` _(read-only)_

Neighbour to which this linked belt is connected to, if any.

Can also be used on entity ghost if it contains linked-belt.

May return entity ghost which contains linked belt to which connection is made.

### linked_belt_type

**Type:** 

Type of linked belt. Changing type will also flip direction so the belt is out of the same side.

Can only be changed when linked belt is disconnected (has no neighbour set).

Can also be used on entity ghost if it contains linked-belt.

### loader_belt_stack_size_override

**Type:** `uint8`

The belt stack size override for this loader. Set to `0` to disable. Writing this value requires [LoaderPrototype::adjustable_belt_stack_size](prototype:LoaderPrototype::adjustable_belt_stack_size) to be `true`.

### loader_container

**Type:** `LuaEntity` _(read-only)_

The container entity this loader is pointing at/pulling from depending on the [LuaEntity::loader_type](runtime:LuaEntity::loader_type), if any.

### loader_filter_mode

**Type:** 

The filter mode for this loader. `nil` if this loader does not support filters.

### loader_type

**Type:** 

Whether this loader gets items from or puts item into a container.

### localised_description

**Type:** `LocalisedString` _(read-only)_



### localised_name

**Type:** `LocalisedString` _(read-only)_

Localised name of the entity.

### logistic_cell

**Type:** `LuaLogisticCell` _(read-only)_

The logistic cell this entity is a part of. Will be `nil` if this entity is not a part of any logistic cell.

### logistic_network

**Type:** `LuaLogisticNetwork`

The logistic network this entity is a part of, or `nil` if this entity is not a part of any logistic network.

### max_health

**Type:** `float` _(read-only)_

Max health of this entity.

### minable

**Type:** `boolean`

Not minable entities can still be destroyed.

Tells if entity reports as being minable right now. This takes into account minable_flag and entity specific conditions (for example rail under rolling stocks is not minable, vehicle with passenger is not minable).

Write to this field since 2.0.26 is deprecated and it will result in write to minable_flag instead.

### minable_flag

**Type:** `boolean`

Script controlled flag that allows entity to be mined.

### mining_drill_filter_mode

**Type:** 

The filter mode for this mining drill. `nil` if this mining drill doesn't have filters.

### mining_progress

**Type:** `double`

The mining progress for this mining drill. Is a number in range [0, mining_target.prototype.mineable_properties.mining_time]. `nil` if this isn't a mining drill.

### mining_target

**Type:** `LuaEntity` _(read-only)_

The mining target, if any.

### mirroring

**Type:** `boolean`

If the entity is currently mirrored. This state is referred to as `flipped` elsewhere, such as on the [on_player_flipped_entity](runtime:on_player_flipped_entity) event.

### name

**Type:** `string` _(read-only)_

Name of the entity prototype. E.g. "inserter" or "fast-inserter".

### name_tag

**Type:** `string`

Name tag of this entity. Returns `nil` if entity has no name tag. When name tag is already used by other entity, the name will be removed from the other entity. Entity name tags can also be set in the entity "extra settings" GUI in the map editor.

### neighbour_bonus

**Type:** `double` _(read-only)_

The current total neighbour bonus of this reactor.

### neighbours

**Type:**  _(read-only)_

A list of neighbours for certain types of entities. Applies to underground belts, walls, gates, reactors, cliffs, and pipe-connectable entities.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### operable

**Type:** `boolean`

Player can't open gui of this entity and he can't quick insert/input stuff in to the entity when it is not operable.

### orientation

**Type:** `RealOrientation`

The smooth orientation of this entity.

### owned_plants

**Type:** ``LuaEntity`[]` _(read-only)_

Plants registered by this agricultural tower. One plant can be registered in multiple agricultural towers.

### parameters

**Type:** `ProgrammableSpeakerParameters`



### pickup_position

**Type:** `MapPosition`

Where the inserter will pick up items from.

Inserters must have `allow_custom_vectors` set to true on their prototype to allow changing the pickup position.

### pickup_target

**Type:** `LuaEntity`

The entity this inserter will attempt to pick up items from. If there are multiple possible entities at the pick-up point, writing to this attribute allows a mod to choose which one to pick up items from. The entity needs to collide with the tile box under the pick-up position. `nil` if there is no entity to pull items from.

### player

**Type:** `LuaPlayer` _(read-only)_

The player connected to this character, if any.

### pollution_bonus

**Type:** `double` _(read-only)_

The pollution bonus of this entity.

### power_production

**Type:** `double`

The power production specific to the ElectricEnergyInterface entity type.

### power_switch_state

**Type:** `boolean`

The state of this power switch.

### power_usage

**Type:** `double`

The power usage specific to the ElectricEnergyInterface entity type.

### previous_recipe

**Type:** `RecipeIDAndQualityIDPair` _(read-only)_

The previous recipe this furnace was using, if any.

### procession_tick

**Type:** `MapTick`

how far into the current procession the cargo pod is.

### productivity_bonus

**Type:** `double` _(read-only)_

The productivity bonus of this entity.

This includes force based bonuses as well as beacon/module bonuses.

### products_finished

**Type:** `uint`

The number of products this machine finished crafting in its lifetime.

### prototype

**Type:** `LuaEntityPrototype` _(read-only)_

The entity prototype of this entity.

### proxy_target

**Type:** `LuaEntity` _(read-only)_

The target entity for this item-request-proxy, if any.

### proxy_target_entity

**Type:** `LuaEntity`

Entity of which inventory is exposed by this ProxyContainer

### proxy_target_inventory

**Type:** `defines.inventory`

Inventory index of the inventory that is exposed by this ProxyContainer

### pump_rail_target

**Type:** `LuaEntity` _(read-only)_

The rail target of this pump, if any.

### quality

**Type:** `LuaQualityPrototype` _(read-only)_

The quality of this entity.

Not all entities support quality and will give the "normal" quality back if they don't.

### radar_scan_progress

**Type:** `float` _(read-only)_

The current radar scan progress, as a number in range `[0, 1]`.

### rail_layer

**Type:** `defines.rail_layer` _(read-only)_

Gets rail layer of a given signal

### recipe_locked

**Type:** `boolean`

When locked; the recipe in this assembling machine can't be changed by the player.

### relative_turret_orientation

**Type:** `RealOrientation`

The relative orientation of the vehicle turret, artillery turret, artillery wagon. `nil` if this entity isn't a vehicle with a vehicle turret or artillery turret/wagon.

Writing does nothing if the vehicle doesn't have a turret.

### removal_plan

**Type:** ``BlueprintInsertPlan`[]`

The removal plan for this item request proxy.

### remove_unfiltered_items

**Type:** `boolean`

Whether items not included in this infinity container filters should be removed from the container.

### render_player

**Type:** `LuaPlayer`

The player that this `simple-entity-with-owner`, `simple-entity-with-force`, or `highlight-box` is visible to. `nil` when this entity is rendered for all players.

### render_to_forces

**Type:** `ForceSet`

The forces that this `simple-entity-with-owner` or `simple-entity-with-force` is visible to. `nil` or an empty array when this entity is rendered for all forces.

Reading will always give an array of [LuaForce](runtime:LuaForce)

### request_from_buffers

**Type:** `boolean`

Whether this requester chest is set to also request from buffer chests.

Useable only on entities that have requester slots.

### result_quality

**Type:** `LuaQualityPrototype`

The quality produced when this crafting machine finishes crafting. `nil` when crafting is not in progress.

Note: Writing `nil` is not allowed.

### robot_order_queue

**Type:** ``WorkerRobotOrder`[]` _(read-only)_

Get the current queue of robot orders.

### rocket

**Type:** `LuaEntity` _(read-only)_

The rocket silo rocket this cargo pod is attached to, or rocket silo rocket attached to this rocket silo - if any.

### rocket_parts

**Type:** `uint`

Number of rocket parts in the silo.

### rocket_silo_status

**Type:** `defines.rocket_silo_status` _(read-only)_

The status of this rocket silo entity.

### rotatable

**Type:** `boolean`

When entity is not to be rotatable (inserter, transport belt etc), it can't be rotated by player using the R key.

Entities that are not rotatable naturally (like chest or furnace) can't be set to be rotatable.

### secondary_bounding_box

**Type:** `BoundingBox` _(read-only)_

The secondary bounding box of this entity or `nil` if it doesn't have one. This only exists for curved rails, and is automatically determined by the game.

### secondary_selection_box

**Type:** `BoundingBox` _(read-only)_

The secondary selection box of this entity or `nil` if it doesn't have one. This only exists for curved rails, and is automatically determined by the game.

### selected_gun_index

**Type:** `uint`

Index of the currently selected weapon slot of this character, car, or spidertron. `nil` if this entity doesn't have guns.

### selection_box

**Type:** `BoundingBox` _(read-only)_

[LuaEntityPrototype::selection_box](runtime:LuaEntityPrototype::selection_box) around entity's given position and respecting the current entity orientation.

### shooting_target

**Type:** `LuaEntity`

The shooting target for this turret, if any. Can't be set to `nil` via script.

### signal_state

**Type:** `defines.signal_state` _(read-only)_

The state of this rail signal.

### spawn_shift

**Type:** `double` _(read-only)_



### spawning_cooldown

**Type:** `double` _(read-only)_



### speed

**Type:** `float`

The current speed if this is a car, rolling stock, projectile or spidertron, or the maximum speed if this is a unit. The speed is in tiles per tick. `nil` if this is not a car, rolling stock, unit, projectile or spidertron.

Only the speed of units, cars, and projectiles are writable.

### speed_bonus

**Type:** `double` _(read-only)_

The speed bonus of this entity.

This includes force based bonuses as well as beacon/module bonuses.

### splitter_filter

**Type:** `ItemFilter`

The filter for this splitter, if any is set.

### splitter_input_priority

**Type:** 

The input priority for this splitter.

### splitter_output_priority

**Type:** 

The output priority for this splitter.

### stack

**Type:** `LuaItemStack` _(read-only)_



### status

**Type:** `defines.entity_status` _(read-only)_

The status of this entity, if any.

This is always the actual status of the entity, even if [LuaEntity::custom_status](runtime:LuaEntity::custom_status) is set.

### sticked_to

**Type:** `LuaEntity` _(read-only)_

The entity this sticker is sticked to.

### sticker_vehicle_modifiers

**Type:** `unknown` _(read-only)_

The vehicle modifiers applied to this entity through the attached stickers.

### stickers

**Type:** ``LuaEntity`[]` _(read-only)_

The sticker entities attached to this entity, if any.

### storage_filter

**Type:** `ItemIDAndQualityIDPair`

The storage filter for this logistic storage container.

Useable only on logistic containers with the `"storage"` [logistic_mode](runtime:LuaEntityPrototype::logistic_mode).

### supports_direction

**Type:** `boolean` _(read-only)_

Whether the entity has direction. When it is false for this entity, it will always return north direction when asked for.

### tags

**Type:** `Tags`

The tags associated with this entity ghost. `nil` if this is not an entity ghost or when the ghost has no tags.

### temperature

**Type:** `double`

The temperature of this entity's heat energy source. `nil` if this entity does not use a heat energy source.

### tick_grown

**Type:** `MapTick`

The tick when this plant is fully grown.

### tick_of_last_attack

**Type:** `uint`

The last tick this character entity was attacked.

### tick_of_last_damage

**Type:** `uint`

The last tick this character entity was damaged.

### tile_height

**Type:** `uint` _(read-only)_

Specifies the tiling size of the entity, is used to decide, if the center should be in the center of the tile (odd tile size dimension) or on the tile border (even tile size dimension). Uses the current direction of the entity.

### tile_width

**Type:** `uint` _(read-only)_

Specifies the tiling size of the entity, is used to decide, if the center should be in the center of the tile (odd tile size dimension) or on the tile border (even tile size dimension). Uses the current direction of the entity.

### time_to_live

**Type:** `uint64`

The ticks left before a combat robot, highlight box, smoke, or sticker entity is destroyed.

### time_to_next_effect

**Type:** `uint`

The ticks until the next trigger effect of this smoke-with-trigger.

### timeout

**Type:** `uint`

The timeout that's left on this landmine in ticks. It describes the time between the landmine being placed and it being armed.

### to_be_looted

**Type:** `boolean`

Will this item entity be picked up automatically when the player walks over it?

### torso_orientation

**Type:** `RealOrientation`

The torso orientation of this spider vehicle.

### train

**Type:** `LuaTrain` _(read-only)_

The train this rolling stock belongs to, if any. `nil` if this is not a rolling stock.

### train_stop_priority

**Type:** `uint8`

Priority of this train stop.

### trains_count

**Type:** `uint` _(read-only)_

Amount of trains related to this particular train stop. Includes train stopped at this train stop (until it finds a path to next target) and trains having this train stop as goal or waypoint.

Train may be included multiple times when braking distance covers this train stop multiple times.

Value may be read even when train stop has no control behavior.

### trains_in_block

**Type:** `uint` _(read-only)_

The number of trains in this rail block for this rail entity.

### trains_limit

**Type:** `uint`

Amount of trains above which no new trains will be sent to this train stop. Writing nil will disable the limit (will set a maximum possible value).

When a train stop has a control behavior with wire connected and set_trains_limit enabled, this value will be overwritten by it.

### tree_color_index

**Type:** `uint8`

Index of the tree color.

### tree_color_index_max

**Type:** `uint8` _(read-only)_

Maximum index of the tree colors.

### tree_gray_stage_index

**Type:** `uint8`

Index of the tree gray stage

### tree_gray_stage_index_max

**Type:** `uint8` _(read-only)_

Maximum index of the tree gray stages.

### tree_stage_index

**Type:** `uint8`

Index of the tree stage.

### tree_stage_index_max

**Type:** `uint8` _(read-only)_

Maximum index of the tree stages.

### type

**Type:** `string` _(read-only)_

The entity prototype type of this entity.

### unit_number

**Type:** `uint64` _(read-only)_

A unique number identifying this entity for the lifetime of the save. These are allocated sequentially, and not re-used (until overflow).

Only entities inheriting from [EntityWithOwnerPrototype](prototype:EntityWithOwnerPrototype), as well as [ItemRequestProxyPrototype](prototype:ItemRequestProxyPrototype) and [EntityGhostPrototype](prototype:EntityGhostPrototype) are assigned a unit number. Returns `nil` otherwise.

### units

**Type:** ``LuaEntity`[]` _(read-only)_

The units associated with this spawner entity.

### use_filters

**Type:** `boolean`

If set to 'true', this inserter will use filtering logic.

This has no effect if the prototype does not support filters.

### use_transitional_requests

**Type:** `boolean`

When true, the rocket silo will request items for space platforms in orbit.

Setting the value will have no effect when the silo doesn't support logistics.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### valve_threshold_override

**Type:** `float`

The threshold override of this valve, or `nil` if an override is not defined.

If no override is defined, the threshold is taken from [LuaEntityPrototype::valve_threshold](runtime:LuaEntityPrototype::valve_threshold).

### vehicle_automatic_targeting_parameters

**Type:** `VehicleAutomaticTargetingParameters`

Read when this spidertron auto-targets enemies

