-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";" .. os.getenv("XDG_DATA_HOME") .. "/sketchybar_lua/?.so"

os.execute("(cd helpers && make)")
