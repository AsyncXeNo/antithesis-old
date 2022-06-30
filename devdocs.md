# DEV DOCS

## TABLE DEFINITIONS

### Components

##### Animator Transitions

```lua
{
    -- Default state is the first state provided in the states table
    -- All variables mentioned in condition have to be provided in the variables table
    {
        ["from"] = <str>,
        ["to"] = <str>,
        ["condition"] = {
            <str> -- [[
                (variable operator value)
                ([!]boolean variable)
            ]]
            <str> -- [[
                Seperate using "AND"s and "OR"s
                OR > AND (Precedence)
            ]]
            ...
            <str> -- [[
                (variable operator value)
                ([!]boolean variable)
            ]]
        }
    },
    ...
}
```

##### Bezier Curve Path for Movement

```lua
{
    -- Each pair is a point
    {
        -- Curve 1
        -- Start point: automatically {0, 0}
        {<int>, <int>}, -- Control point 1
        {<int>, <int>}, -- Control point 2
        {<int>, <int>}  -- End point
    },
    {
        -- Curve 2
        -- Start point: Previous end point
        -- Control point 1: Mirror to previous control point 2
        {<int>, <int>}, -- Control point 2
        {<int>, <int>} -- End point
    },
    ...
    {
        -- Last curve
        {<int>, <int>},
        {<int>, <int>}
    }
}
```

##### Timeline

```lua
{
    {
        -- Action 1
    },
    {
        -- Action 2
    },
    ...
}
```

Types of actions:
- Move to `arg1: {x,y}` with lerp `arg2: t`
- Shoot with `arg1: type` pattern, `arg2: radius` away, of specification `arg3, arg4, arg5... arg7`, using `arg8: bullet` bullet


##### Collision Detection QuadTree

```lua
{
    {
        {
            ...
        },
        {
            ...
        },
        {
            ...
        },
        {
            ...
        },

        ["objs"] = {
            <entity> = true,
            <entity> = true,
            ...
        },
        
        ["bounds"] = {
            {
                x = <int>,
                y = <int>
            },
            {
                x = <int>,
                y = <int>
            }
        }
    },  
    {
        {
            ...
        },
        {
            ...   
        },
        {
            ...   
        },
        {
            ...   
        },
        
        ["objs"] = {
            <entity> = true,
            <entity> = true,
            ...
        },
        
        ["bounds"] = {
            {
                x = <int>,
                y = <int>
            },
            {
                x = <int>,
                y = <int>
            }
        }
    },
    {
        {
            ...
        },
        {
            ...   
        },
        {
            ...   
        },
        {
            ...   
        },
        
        ["objs"] = {
            <entity> = true,
            <entity> = true,
            ...
        },
        
        ["bounds"] = {
            {
                x = <int>,
                y = <int>
            },
            {
                x = <int>,
                y = <int>
            }
        }
    },
    {
        {
            ...
        },
        {
            ...   
        },
        {
            ...   
        },
        {
            ...   
        },
        
        ["objs"] = {
            <entity> = true,
            <entity> = true,
            ...
        },
        
        ["bounds"] = {
            {
                x = <int>,
                y = <int>
            },
            {
                x = <int>,
                y = <int>
            }
        }
    },

    ["objs"] = {
        <entity> = true,
        <entity> = true,
        ...
    },
    ["bounds"] = {
        {
            x = <int>,
            y = <int>
        },
        {
            x = <int>,
            y = <int>
        }
    }
}
```
