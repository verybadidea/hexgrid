# hexgrid
Hexagonal grid implementation in FreeBASIC based on https://www.redblobgames.com/grids/hexagons/

# To do
- Demo: path finding
- Demo: Hexatris
- Movement Range -> return list of hex tiles?
- Obstacles / path-finding -> return list of hex tiles?
- 60° rotation around other hex 
- Ring / circle -> return list of hex tiles?
- Spiral ring -> return list of hex tiles?
- Field of view (if needed, complex)
- Name change: hex_axial --> hex, hex_cube --> cube
- Offset coordinates (Neighbors, Distance, Offset coordinates)
- Doubled coordinates (Neighbors, Distance, Hex_to_pixel)
- Make pt_dbl_list obsolete

# Games notes

Flow:
- Piece placed?
  -> Check for lines: mark_lines(), uses: scan_mark_line()
- If lines found?
  -> Delay, call: drop_lines(), uses: drop_section()

