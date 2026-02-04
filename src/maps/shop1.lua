return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 22,
  height = 12,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 8,
  nextobjectid = 194,
  properties = {},
  tilesets = {
    {
      name = "walls",
      firstgid = 1,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 17,
      image = "../assets/tilesets/walls.png",
      imagewidth = 272,
      imageheight = 368,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 391,
      tiles = {}
    },
    {
      name = "Interiors",
      firstgid = 392,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 16,
      image = "../assets/tilesets/Interiors.png",
      imagewidth = 256,
      imageheight = 1536,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 1536,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 22,
      height = 12,
      id = 1,
      name = "floor",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 220, 220, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 220, 220, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 220, 220, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 220, 220, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 217, 217,
        217, 217, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 217, 217,
        217, 217, 220, 220, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217,
        217, 217, 220, 220, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217, 217
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 22,
      height = 12,
      id = 2,
      name = "hills",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        296, 332, 333, 331, 332, 333, 331, 332, 333, 331, 332, 332, 332, 331, 332, 333, 331, 332, 333, 331, 332, 3221225768,
        296, 349, 350, 348, 349, 350, 348, 349, 350, 348, 349, 349, 349, 348, 349, 350, 348, 349, 350, 348, 349, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3221225768,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        350, 0, 0, 0, 307, 308, 309, 307, 308, 309, 307, 308, 309, 307, 308, 309, 307, 308, 309, 307, 308, 309
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 22,
      height = 12,
      id = 3,
      name = "decor",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1834, 1835, 1880, 1881, 1880, 1881, 1880, 1881, 1880, 1881, 1880, 1881, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1850, 1851, 1896, 1897, 1896, 1897, 1896, 1897, 1896, 1897, 1896, 1897, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1866, 1867, 1912, 1913, 1912, 1913, 1912, 1913, 1912, 1913, 1912, 1913, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 22,
      height = 12,
      id = 5,
      name = "decor2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1836, 1837, 1882, 1883, 1884, 1885, 1882, 1883, 1884, 1885, 1884, 1885, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1852, 1853, 1898, 1899, 1900, 1901, 1898, 1899, 1900, 1901, 1900, 1901, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1868, 1869, 1914, 1915, 1916, 1917, 1914, 1915, 1916, 1917, 1916, 1917, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 6,
      name = "colliders",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "rectangle",
          x = 336,
          y = 16,
          width = 16,
          height = 176,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 174,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 16,
          width = 16,
          height = 176,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 7,
      name = "props",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 175,
          name = "walls/wall_3_middle",
          type = "",
          shape = "point",
          x = 184,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 176,
          name = "walls/wall_3_left",
          type = "",
          shape = "point",
          x = 168,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 177,
          name = "walls/wall_3_right",
          type = "",
          shape = "point",
          x = 200,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 178,
          name = "walls/wall_3_left",
          type = "",
          shape = "point",
          x = 216,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 179,
          name = "walls/wall_3_middle",
          type = "",
          shape = "point",
          x = 136,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 180,
          name = "walls/wall_3_left",
          type = "",
          shape = "point",
          x = 120,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 181,
          name = "walls/wall_3_right",
          type = "",
          shape = "point",
          x = 152,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 182,
          name = "walls/wall_3_middle",
          type = "",
          shape = "point",
          x = 88,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 183,
          name = "walls/wall_3_left",
          type = "",
          shape = "point",
          x = 72,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 184,
          name = "walls/wall_3_right",
          type = "",
          shape = "point",
          x = 104,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 185,
          name = "walls/wall_3_middle",
          type = "",
          shape = "point",
          x = 280,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 186,
          name = "walls/wall_3_left",
          type = "",
          shape = "point",
          x = 264,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 187,
          name = "walls/wall_3_right",
          type = "",
          shape = "point",
          x = 296,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 188,
          name = "walls/wall_2_left",
          type = "",
          shape = "point",
          x = 312,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 189,
          name = "walls/wall_3_middle",
          type = "",
          shape = "point",
          x = 232,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 190,
          name = "walls/wall_3_right",
          type = "",
          shape = "point",
          x = 248,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 191,
          name = "walls/wall_3_middle",
          type = "",
          shape = "point",
          x = 328,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 192,
          name = "walls/wall_3_right",
          type = "",
          shape = "point",
          x = 344,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        },
        {
          id = 193,
          name = "walls/wall_2_left",
          type = "",
          shape = "point",
          x = 8,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["\ntransparency_when_inside"] = true,
            ["add_y"] = 50
          }
        }
      }
    }
  }
}
