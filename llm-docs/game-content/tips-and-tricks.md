# Factorio Tips and Tricks

This document contains helpful tips and tricks for playing Factorio.

## Active provider chest

[entity=active-provider-chest] actively tries to push its items to the logistic network.\nIf there are no requests for an item in an active provider chest, they will be moved to [entity=storage-chest].

## Additional info (Alt-mode)

Press __CONTROL__show-info__ to toggle the detailed info overlay, also known as "Alt-mode".

## Automatic obstacle traversing

Dragging [entity=transport-belt] over an obstacle will automatically build [entity=underground-belt] transition when possible.

## Belt lanes

[entity=transport-belt] have two lanes that can be used to transport items and they can be used for different resources.\n[entity=inserter] can pick up items from both lanes, but put items only on the far lane.

## Buffer chest

[entity=buffer-chest] acts as both a [entity=requester-chest] and [entity=passive-provider-chest].\nThey provide items for construction jobs, personal logistics, and requester chests with 'Request from buffer chests' enabled.

## Build by dragging

The quickest way to build in a straight line, such as a setup of [entity=stone-furnace], is to press __CONTROL__build__ and hold while running in the desired direction.

## Bulk crafting

When hovering a crafting slot:\n - __ALT_CONTROL__1__craft-5__ to craft 5.\n - __ALT_CONTROL__1__craft-all__ to craft as much as possible.

## Burner inserter refueling

[entity=burner-inserter] can be refueled by other inserters, but they can also refuel themselves when working with fuel.

## Circuit network

The circuit network is a system that allows transfer of information between machines.\nYou can connect machines to the circuit network using [shortcut=give-red-wire] and [shortcut=give-green-wire].\nThe network can carry integer values of -2³¹(-2,147,483,648) .. 2³¹(2,147,483,647) individually for each signal type.\nIt is not required to use the circuit network to finish the game, but allows a lot of fun contraptions or fine tuned factory optimizations that wouldn't be possible without it.

## Clear cursor

When holding an item, you can clear it using __CONTROL__clear-cursor__, which will return it to the [img=utility/hand] slot in the source inventory.\nIt also cancels rail planning, wire dragging and selection boxes.

## Construction robots

[entity=construction-robot] fulfills construction, deconstruction, upgrade and repair orders from the logistic network.\nConstruction orders are created by ghost building, [item=blueprint] usage, or when a friendly building is destroyed and needs to be rebuilt.\nDeconstruction orders are created by selecting the desired entities by [item=deconstruction-planner].\nUpgrade orders are created by the usage of [item=upgrade-planner].\nThese orders are also created when using the undo feature.

## Copy paste

The copy tool (__CONTROL__copy__) allows you to save selection to clipboard.\nThe paste tool (__CONTROL__paste__) retrieves the last copied selection to be built.\n__CONTROL__cycle-clipboard-forwards__ and __CONTROL__cycle-clipboard-backwards__ allows you to scroll through the clipboard history.

## Copy-paste entity settings

__CONTROL__copy-entity-settings__ and __CONTROL__paste-entity-settings__ allows you to copy settings between entities.\nFor instance, you can copy-paste between [entity=assembling-machine-2] to set the recipe, or between chests to set the inventory limit.\n__ALT_CONTROL__1__paste-entity-settings__ and drag can paste to multiple entities with a single stroke.

## Copy-paste entity settings

__CONTROL__copy-entity-settings__ and __CONTROL__paste-entity-settings__ allows you to copy settings between entities.\nFor instance, you can copy-paste between [entity=assembling-machine-2] to set the recipe, or between chests to set the inventory limit.\nHold down __CONTROL__paste-entity-settings__ and move using __CONTROL__move__ to quickly paste to multiple entities.

## Copy-paste filters

You can copy-paste between entities with configurable filters, requests, or filtered inventory slots, such as [entity=fast-inserter], [entity=splitter], [entity=requester-chest] or [entity=cargo-wagon].

## Copy-paste requester chest

You can copy-paste between [entity=requester-chest] to copy the logistic requests.\nYou can also copy-paste from an [entity=assembling-machine-2] to a [entity=requester-chest] to set the logistic request based on the recipe.

## Copy-paste spidertron

Copy-pasting between [entity=spidertron] will copy the color and logistic requests.\nIt will also try to copy the equipment grid, inserting the equipment from the player inventory if the items are available.

## Copy-paste trains

You can copy-paste between [entity=locomotive] to copy schedule and color.\nYou can copy-paste between [entity=train-stop] to copy the stop name and color.\nLastly you can copy-paste between [entity=locomotive] and [entity=train-stop] either way to copy the color.

## Dragging electric poles

If you build [entity=small-electric-pole] by dragging, it will automatically be built at the maximum connection distance.

## Dragging underground belts

If you build [entity=underground-belt] or [entity=pipe-to-ground] by dragging, it will automatically be built at the maximum connection distance.

## Electric network

Electric networks transfer energy from the producers like [entity=steam-engine] or [entity=solar-panel] to the consumers evenly.\n__ALT_CONTROL__1__open-gui__ on an electric pole to show the statistics of its electric network.

## Electric pole connections

Electric poles will automatically connect to other electric poles within their 'wire reach'.\nConnections can be manually added or removed using [shortcut=give-copper-wire].\nAll electric pole connections can be removed using __CONTROL__remove-pole-cables__ on an electric pole.

## Entity pipette

Use __CONTROL__pipette__ to put the selected entity in your cursor.\nWhen used in remote view, a ghost of the selected entity will be put in your cursor instead.

## Entity transfers

__ALT_CONTROL__1__fast-entity-transfer__ on an entity to take items from it.\n__ALT_CONTROL__1__fast-entity-transfer__ while holding an item to put it into the selected entity.\n\n\nThe tutorial teaches you different ways of transferring items to and from entities without opening them.

## Fast belt bending

Pressing __CONTROL__rotate__ while dragging [entity=transport-belt] allows you to make seamless bends quickly.

## Fast replace

Building over an entity of the same type and size will perform a fast replace. Fast replacing will preserve properties of the original entity, such as the inventory contents and selected recipe.

## Fast replace belt & splitter

You can fast replace [entity=transport-belt] with [entity=splitter] and vice versa.

## Fast replace belt & underground belt

You can fast replace [entity=transport-belt] with [entity=underground-belt] and vice versa.\nAny belts in between the entrance and exit of the underground belt will be mined automatically.\nThis fast replace feature also applies to [entity=pipe] and [entity=pipe-to-ground].

## Fast replace direction

You can use fast replace to quickly change the direction of entities.

## Gate over rail

[entity=gate] can be built over any vertical or horizontal [entity=straight-rail].\nTrains will automatically open the gate to pass, and will not leave a hole in your defenses.

## Ghost building

__ALT_CONTROL__1__build-ghost__ while holding a buildable item to build it as an entity ghost.\nEntity ghosts will be automatically built by any logistic networks in range.

## Ghost rail planner

The ghost rail planner is used to plan long stretches of new rail ghosts.\nTo use the ghost planner, hold __CONTROL_MODIFIER__build-ghost__ while rail planning.\nYou can also hold __CONTROL_MODIFIER__build-with-obstacle-avoidance__ to ghost rail plan with obstacle avoidance.

## Inserters

Inserters pick items up from one direction and place them on the opposite tile.\nThey can move items to and from [entity=transport-belt], [entity=iron-chest], [entity=burner-mining-drill], [entity=stone-furnace], and other machines.

## Insertion limits

An Inserter doesn't always fill up the entire target inventory. This allows other inserters to pick up their share of the items.\nFor example, if a [entity=boiler] has 5 or more items of [item=coal] in it, an inserter will not insert any more. This allows the other fuel to travel further down the transport belt to other boilers, instead of the first in the queue hoarding everything.\nThis also applies to [entity=gun-turret], [entity=assembling-machine-1], [entity=stone-furnace], [entity=lab] and more.

## Limiting chests

Chests can have their available inventory slots limited by selecting the red "X" inventory slot, and then blocking the desired slots.\nInserters will not be able to fill the blocked slots, so overall it reduces the chests capacity and prevents over-production.

## Logistic network

The logistic network is a powerful automated delivery network that utilizes flying robots to move items and perform automated construction.\nIt has 3 major components:\n - [entity=roboport] defines the area of network coverage, acts as a charging and storage point for robots.\n - [entity=logistic-robot] fulfills logistic orders and [entity=construction-robot] performs construction orders.\n - [tooltip=Provider chests,tips-and-tricks-item-description.storage-chest-list] supply the network with items.

## Long-handed inserters

[entity=long-handed-inserter] is an electric inserter that picks up and places items two tiles from its location instead of the usual one.

## Low power

If your power consumption is greater than your production capacity, your factory machines will work more slowly due to the insufficient supply.\nPay attention to the speed of your machines, if you want to identify insufficient power production before it's too late.\nThe best way to make sure you have enough power, is to check the electric network statistics and make sure the 'Satisfaction' bar is green and full.

## Passive provider chest

[entity=passive-provider-chest] supplies its items to the logistic network.\nThis means any items in the passive provider chests can be taken by robots to fulfill logistic or construction orders.

## Personal logistics

[entity=logistic-robot] moves items from logistic provider chests to fulfill personal logistic requests.\nThe personal logistic request has a minimum and maximum count, and the robots will bring items until you have more than the minimum count.\nIf you have more than the maximum count, the items will be moved to your logistic trash slots, to be taken away by the robots.

## Pole dragging coverage

If you build [entity=small-electric-pole] by dragging along electric machines, none in range will be skipped.

## Power switch connection

__ALT_CONTROL__1__build__ on an entity with [shortcut=give-copper-wire] in your cursor to connect an electric cable to it.\n__ALT_CONTROL__1__remove-pole-cables__ on an entity to remove all cables.

## Pump connection

[entity=pump] will connect to a stationary [entity=fluid-wagon] when they are aligned correctly.\nIt is required for loading and unloading fluids from the [entity=fluid-wagon].

## Rail building

To activate the rail building mode, hold [item=rail] and press __CONTROL__build__ over an existing piece of rail.\n__ALT_CONTROL__1__build__ to confirm the placement of the desired piece of rail.\n__CONTROL__clear-cursor__ deactivates the rail building mode.

## Rail signals advanced

[entity=rail-chain-signal] determines its state based on the signals ahead of it to ensure that a train entering a block will be able to leave it.\nThey are used in conjuction with [entity=rail-signal] to build advanced railway intersections.\n\n\nThe tutorial teaches you how to use rail chain signals to build complex rail intersections and prevent deadlocks.

## Rail signals basic

[entity=rail-signal] divides rails into blocks. Each [entity=locomotive] will read the rail signals to prevent crashing into other trains.\n\n\n\nThe tutorial teaches you how to use rail signals to run multiple trains on the same rail system.

## Repair packs

While holding a [item=repair-pack] in your cursor, press __CONTROL__build__ and hold on an entity to repair it.

## Requester chest

[entity=requester-chest] requests items from the logistic network.\n[entity=logistic-robot] will move items from the logistic network to fulfill the requests.

## Rotating assembling machines

Some recipes require a fluid input to the [entity=assembling-machine-2], such as [recipe=electric-engine-unit]. An assembling machine with a fluid input can be rotated by using __CONTROL__rotate__.

## Shoot targeting

You can shoot enemy targets pressing __CONTROL__shoot-enemy__ with your cursor near the enemy.\nYou can shoot a selected neutral or friendly entity by pressing __CONTROL__shoot-selected__.

## Shoot targeting

You can shoot enemy targets by holding __CONTROL__shoot-enemy__.\nWhen using a controller, all weapons will automatically aim to the closest enemy in an area. Use __CONTROL__look__ to move the automatic targeting area.\nYou can shoot a selected neutral or friendly entity by pressing __CONTROL__shoot-selected__.

## Spidertron control

[entity=spidertron] can be entered using __CONTROL__toggle-driving__, and driven using __CONTROL_MOVE__.\nIt can also be controlled by __CONTROL__give-spidertron-remote__. __CONTROL__use-item__ to send spidertron and __CONTROL__alternative-use-item__ to queue move command.\n__CONTROL__select-for-cancel-deconstruct__ can be used to add another spidertron to the selection and __CONTROL__deselect__ to deselect it.

## Splitters

[entity=splitter] is used to split, combine, or balance belts.\nIncoming items are split equally if there is free space in both outputs, or routed to whatever output is free.\nIt can be configured to filter specific item, or to prioritize one of the inputs/outputs.

## Stack transfers

__CONTROL__stack-transfer__ transfers a single stack.\n__CONTROL__inventory-transfer__ transfers all stacks of the given type. (Selecting an empty slot transfers the whole inventory.)\nUsing __CONTROL_RIGHT_CLICK__ instead of __CONTROL_LEFT_CLICK__ for the controls mentioned above will transfer half the quantity.\n\nThe tutorial explains it in more detail.

## Steam power

[entity=boiler] consumes burnable fuel such as [item=coal] to turn [fluid=water] into [fluid=steam].\n[entity=steam-engine] consumes [fluid=steam] to produce electric energy, which is distributed to consumers in the electric network.

## Storage chest

[entity=storage-chest] stores the items taken from player trash slots and deconstruction orders.\nAny items in the storage chests are also provided to be used for logistic or construction orders.\nStorage chests can be filtered to only accept 1 type of item.

## Train stops

[entity=train-stop] is used to automate item transportation with trains by providing nameable locations for trains to travel to.\n\n\n\nThe tutorial teaches you how to build a train station, and how to set a simple train schedule.

## Train stops with the same name

[entity=train-stop] can share its name with other stops. Trains with that name in the schedule will be able to target any of the stops as their destination.\nYou can set the train limit for each train stop to control this behavior more precisely.

## Trains

Trains are useful for high throughput and long distance transportation.\nTrains can be entered using __CONTROL__toggle-driving__, and driven using __CONTROL_MOVE__.

## Transfer between labs

[entity=inserter] can be used to transfer science packs between [entity=lab].

## Usable items

Some items can be used in other ways than building entities in the world. For instance, you can throw [item=grenade] at enemies to damage them.\n__ALT_CONTROL__1__build__ while holding a usable item in your cursor to apply its action.

## __CONTROL__confirm-gui__ to confirm

All the green buttons in the game can be 'confirmed' using __CONTROL__confirm-gui__.

## __CONTROL__drop-cursor__ to drop items

Press __CONTROL__drop-cursor__ to drop single items from your cursor.\nYou can drop to the ground, on to belts, and into entities.\nHold __CONTROL__drop-cursor__ and drag the cursor across multiple entities to quickly drop single items into each.

## __CONTROL__flip-horizontal__ or __CONTROL__flip-vertical__ to flip entities

Most entities can be flipped, horizontally with __CONTROL__flip-horizontal__ or vertically with __CONTROL__flip-vertical__. You can flip items in your hand, or hover over an entity to flip it in place.

## storage-chest-list

Chests providing its contents ordered by priority:\n[entity=active-provider-chest] Active provider chest\n[entity=buffer-chest] Buffer chest\n[entity=storage-chest] Storage chest\n[entity=passive-provider-chest] Passive provider chest

