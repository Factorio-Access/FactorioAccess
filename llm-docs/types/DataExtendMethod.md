# DataExtendMethod

The data.extend method. It's the primary way to add prototypes to the data table.

The method has two positional function parameters:

- `self` :: [Data](prototype:Data)?: Usually provided by calling `data:extend(otherdata)`, which is syntax sugar for `data.extend(data, otherdata)`.

- `otherdata` :: array[[AnyPrototype](prototype:AnyPrototype)]: A continuous array of non-abstract prototypes.

The data.extend method can also be called with only the `otherdata` argument by calling it directly on data: `data.extend(otherdata)`.

