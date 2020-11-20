---@alias integer number

do
	---Represents the server; only one instance in the global variable `server`.
	---@class Server
	---@field class string 🔒 "Server"
	---@field TPS integer 🔒 How many ticks are in 1 second according to in-game timers (60).
	---@field port integer 🔒
	---@field name string Name shown on the server list, max length of 31.
	---@field password string Empty string for no password, otherwise people will need to type this to join.
	---@field type integer Gamemode number.
	---@field loadedLevel string 🔒 Name of the currently loaded map.
	---@field levelToLoad string
	---@field isLevelLoaded boolean
	---@field gravity number
	---@field defaultGravity number 🔒
	---@field state integer Game state enum. Always networked.
	---@field time integer Time remaining in ticks (see TPS). Always networked.
	---@field sunTime integer Time of day in ticks, where noon is 2592000 (12*60*60*TPS). Always networked.
	---@field version string 🔒 Game build, ex. "36a"
	---@field versionMajor integer 🔒 Major version number, ex. 36
	---@field versionMinor integer 🔒 Minor version number, ex. 1
	---@field numEvents integer 🔒 How many networked events there currently are, resets to 0 when the server resets.
	local Server

	---Reset the game with reason RESET_REASON_LUACALL.
	function Server:reset() end

	---Set the title displayed on the terminal the server is running on.
	---@param title string The title to set.
	function Server:setConsoleTitle(title) end

	---The global Server instance.
	server = Server
end

do
	---Represents a 3D point in the level.
	---@class Vector
	---@field class string 🔒 "Vector"
	---@field x number
	---@field y number
	---@field z number
	local Vector

	---Add other to self.
	---@param other Vector The vector to add.
	function Vector:add(other) end

	---Multiply self by scalar.
	---@param scalar number The scalar to multiply each coordinate by.
	function Vector:mult(scalar) end

	---Replace values with those in another vector.
	---@param other Vector The vector to inherit values from.
	function Vector:set(other) end

	---Create a copy of self.
	---@return Vector clone The created copy.
	function Vector:clone() end

	---Calculate the distance between self and other.
	---@param other Vector The vector to calculate distance to.
	---@return number distance The distance in units.
	function Vector:dist(other) end

	---Calculate the distance between self and other, squared.
	---Much faster as it does not square root the value.
	---@param other Vector The vector to calculate distance to.
	---@return number distanceSquared The distance in units, squared.
	function Vector:distSquare(other) end
end

do
	---Represents the rotation of an object as a 3x3 matrix.
	---@class RotMatrix
	---@field class string 🔒 "RotMatrix"
	---@field x1 number
	---@field y1 number
	---@field z1 number
	---@field x2 number
	---@field y2 number
	---@field z2 number
	---@field x3 number
	---@field y3 number
	---@field z3 number
	local RotMatrix

	---Replace values with those in another matrix.
	---@param other RotMatrix The matrix to inherit values from.
	function RotMatrix:set(other) end

	---Create a copy of self.
	---@return RotMatrix clone The created copy.
	function RotMatrix:clone() end
end

do
	---Represents a connected player, who may or may not be spawned in.
	---💾 = To network changed value to clients, the `update` method needs to be called.
	---💲 = To network changed value to clients, the `updateFinance` method needs to be called.
	---@class Player
	---@field class string 🔒 "Player"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field subRosaID integer See Account.subRosaID
	---@field phoneNumber integer 💲 See Account.phoneNumber
	---@field money integer 💲
	---@field corporateRating integer
	---@field criminalRating integer
	---@field team integer 💾
	---@field teamSwitchTimer integer Ticks remaining until they can switch teams again.
	---@field stocks integer 💲 The amount of shares they own in their company.
	---@field menuTab integer What tab in the menu they are currently in.
	---@field gender integer 💾 0 = female, 1 = male.
	---@field skinColor integer 💾 Starts at 0.
	---@field hairColor integer 💾
	---@field hair integer 💾
	---@field eyeColor integer 💾
	---@field model integer 💾 0 = casual, 1 = suit.
	---@field head integer 💾
	---@field suitColor integer 💾
	---@field tieColor integer 💾 0 = no tie, 1 = the first color.
	---@field necklace integer 💾
	---@field index integer 🔒 The index of the array in memory this is (0-255).
	---@field isActive boolean 💾 Whether or not this exists, only change if you know what you are doing.
	---@field name string 💾 Nickname of this player.
	---@field isAdmin boolean
	---@field isReady boolean
	---@field isBot boolean 💾
	---@field human Human? 💾 The human they currently control.
	---@field connection Connection? 🔒 Their network connection.
	---@field account Account Their account.
	---@field botDestination Vector? The location this bot will walk towards.
	local Player

	---Get a specific action.
	---@param index integer The index between 0 and 63.
	---@return Action action The desired action.
	function Player:getAction(index) end

	---Get a specific menu button.
	---@param index integer The index between 0 and 31.
	---@return MenuButton menuButton The desired menu button.
	function Player:getMenuButton(index) end

	---Fire a network event containing basic info.
	function Player:update() end

	---Fire a network event containing financial info.
	function Player:updateFinance() end

	---Remove self safely and fire a network event.
	function Player:remove() end

	---Create a red chat message only this player receives.
	---@param message string The message to send.
	function Player:sendMessage(message) end
end

do
	---Represents a human, including dead bodies.
	---@class Human
	---@field class string 🔒 "Human"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field stamina integer
	---@field maxStamina integer
	---@field vehicleSeat integer Seat index of the vehicle they are in.
	---@field despawnTime integer Ticks remaining until removal if dead.
	---@field movementState integer 0 = normal, 1 = in midair, 2 = sliding, rest unknown.
	---@field zoomLevel integer 0 = run, 1 = walk, 2 = aim.
	---@field damage integer Level of screen blackness, 0-60.
	---@field pos Vector Position.
	---@field viewYaw number Radians.
	---@field viewPitch number Radians.
	---@field strafeInput number Left to right movement input, -1 to 1.
	---@field walkInput number Backward to forward movement input, -1 to 1.
	---@field inputFlags integer Bitflag of current buttons being pressed.
	---@field lastInputFlags integer Input flags from the last tick.
	---@field health integer Dynamic health, 0-100.
	---@field bloodLevel integer How much blood they have, 0-100. <50 and they will collapse.
	---@field chestHP integer Dynamic chest health, 0-100.
	---@field headHP integer
	---@field leftArmHP integer
	---@field rightArmHP integer
	---@field leftLegHP integer
	---@field rightLegHP integer
	---@field gender integer See Player.gender.
	---@field head integer See Player.head.
	---@field skinColor integer See Player.skinColor.
	---@field hairColor integer See Player.hairColor.
	---@field hair integer See Player.hair.
	---@field eyeColor integer See Player.eyeColor.
	---@field model integer See Player.model.
	---@field suitColor integer See Player.suitColor.
	---@field tieColor integer See Player.tieColor.
	---@field necklace integer See Player.necklace.
	---@field index integer 🔒 The index of the array in memory this is (0-255).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field isAlive boolean
	---@field isImmortal boolean Whether they are immune to bullet and physics damage.
	---@field isOnGround boolean 🔒
	---@field isStanding boolean 🔒
	---@field isBleeding boolean 
	---@field player Player? 🔒 The player controlling this human.
	---@field vehicle Vehicle? The vehicle they are inside.
	---@field rightHandItem Item? 🔒
	---@field leftHandItem Item? 🔒
	---@field rightHandGrab Human? 🔒
	---@field leftHandGrab Human? 🔒
	---@field isAppearanceDirty boolean Whether the appearance fields (model, gender, etc.) are dirty and need to be networked.
	local Human

	---Remove self safely and fire a network event.
	function Human:remove() end

	---Teleport safely to a different position.
	---@param position Vector The position to teleport to.
	function Human:teleport(position) end

	---Speak a message.
	---@param message string The message to say.
	---@param volumeLevel integer The volume to speak at. 0 = whisper, 1 = normal, 2 = yell.
	function Human:speak(message, volumeLevel) end

	---Arm with a gun and magazines.
	---@param weaponType integer The ID of the item type. Must be a weapon.
	---@param magazineCount integer The number of magazines to give.
	function Human:arm(weaponType, magazineCount) end

	---Get a specific bone.
	---@param index integer The index between 0 and 15.
	---@return Bone bone The desired bone.
	function Human:getBone(index) end

	---Get a specific rigid body.
	---@param index integer The index between 0 and 15.
	---@return RigidBody rigidBody The desired rigid body.
	function Human:getRigidBody(index) end

	---Set the velocity of every rigid body.
	---@param velocity Vector The velocity to set.
	function Human:setVelocity(velocity) end

	---Add velocity to every rigid body.
	---@param velocity Vector The velocity to add.
	function Human:addVelocity(velocity) end

	---Mount an item to an inventory slot.
	---@param childItem Item The item to mount.
	---@param slot integer The slot to mount to.
	---@return boolean success Whether the mount was successful.
	function Human:mountItem(childItem, slot) end

	---Apply damage points to a specific bone.
	---@param boneIndex integer The index of the bone to apply damage to.
	---@param damage integer The amount of damage to apply.
	function Human:applyDamage(boneIndex, damage) end
end


do
	---Represents an item in the world or someone's inventory.
	---💾 = To network changed value to clients, the `update` method needs to be called.
	---@class Item
	---@field class string 🔒 "Item"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field type integer 💾
	---@field despawnTime integer Ticks remaining until removal.
	---@field parentSlot integer The slot this item occupies if it has a parent.
	---@field parentHuman Human? The human this item is mounted to, if any.
	---@field parentItem Item? The item this item is mounted to, if any.
	---@field pos Vector Position.
	---@field vel Vector Velocity.
	---@field rot RotMatrix Rotation.
	---@field bullets integer How many bullets are inside this item.
	---@field computerCurrentLine integer
	---@field computerTopLine integer Which line is at the top of the screen.
	---@field computerCursor integer The location of the cursor, -1 for no cursor.
	---@field index integer 🔒 The index of the array in memory this is (0-1023).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field hasPhysics boolean Whether this item is currently physically simulated.
	---@field physicsSettled boolean Whether this item is settled by gravity.
	---@field physicsSettledTimer integer How many ticks the item has been settling. Once it has reached 60, it will be settled.
	---@field rigidBody RigidBody The rigid body representing the physics of this item.
	---@field grenadePrimer Player? The player who primed this grenade.
	local Item

	---Fire a network event containing basic info.
	function Item:update() end

	---Remove self safely and fire a network event.
	function Item:remove() end

	---Mount another item onto this item.
	---Ex. a magazine to this gun.
	---@param childItem Item The child item to mount to this item.
	---@param slot integer The slot to mount the child item to.
	---@return boolean success Whether the mount was successful.
	function Item:mountItem(childItem, slot) end

	---Remove this item from any parent, back into the world.
	---@return boolean success Whether the unmount was successful.
	function Item:unmount() end

	---Speak a message.
	---The item does not need to be a phone type.
	---@param message string The message to say.
	---@param volumeLevel integer The volume to speak at. 0 = whisper, 1 = normal, 2 = yell.
	function Item:speak(message, volumeLevel) end

	---Explode like a grenade, whether or not it is one.
	---Does not alter or remove the item.
	function Item:explode() end

	---Set the text displayed on this item.
	---Visible if it is a Memo or a Newspaper item.
	---@param memo string The memo to set. Max 1023 characters.
	function Item:setMemo(memo) end

	---Update the color and text of a line and network it.
	---Only works if this item is a computer.
	---@param lineIndex integer Which line to transmit.
	function Item:computerTransmitLine(lineIndex) end

	---Set the text to display on a line. Does not immediately network.
	---Only works if this item is a computer.
	---@param lineIndex integer Which line to edit.
	---@param text string The text to set the line to. Max 63 characters.
	function Item:computerSetLine(lineIndex, text) end

	---Set the color of a character on screen. Does not immediately network.
	---Only works if this item is a computer.
	---Uses the 16 CGA colors for foreground and background separately.
	---@param lineIndex integer Which line to edit.
	---@param columnIndex integer Which column to edit.
	---@param color integer The color to set, between 0x00 and 0xFF.
	function Item:computerSetColor(lineIndex, columnIndex, color) end
end

do
	---Represents a car, train, or helicopter.
	---💾 = To network changed value to clients, the `updateType` method needs to be called.
	---@class Vehicle
	---@field class string 🔒 "Vehicle"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field type integer 💾
	---@field controllableState integer 0 = cannot be controlled, 1 = car, 2 = helicopter.
	---@field health integer 0-100
	---@field color integer 💾 0 = black, 1 = red, 2 = blue, 3 = silver, 4 = white, 5 = gold.
	---@field pos Vector Position.
	---@field vel Vector Velocity.
	---@field rot RotMatrix Rotation.
	---@field gearX number Left to right stick shift position, 0 to 2.
	---@field gearY number Forward to back stick shift position, -1 to 1.
	---@field steerControl number Left to right wheel position, -0.75 to 0.75.
	---@field gasControl number Brakes to full gas, -1 to 1.
	---@field index integer 🔒 The index of the array in memory this is (0-511).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field lastDriver Player? 🔒 The last person to drive the vehicle.
	---@field rigidBody RigidBody 🔒 The rigid body representing the physics of this vehicle.
	local Vehicle

	---Fire a network event containing basic info.
	function Vehicle:updateType() end

	---Fire a network event to make a part appear to break.
	---Also used to visually toggle train doors.
	---@param kind integer The kind of part. 0 = window, 1 = tire, 2 = entire body.
	---@param position Vector The global position of the destruction.
	---@param normal Vector The normal of the destruction.
	function Vehicle:updateDestruction(kind, partIndex, position, normal) end

	---Remove self safely and fire a network event.
	function Vehicle:remove() end
end

do
	---Represents a rigid body currently in use by the physics engine.
	---@class RigidBody
	---@field class string 🔒 "RigidBody"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field type integer 0 = bone, 1 = car body, 2 = wheel, 3 = item.
	---@field mass number In kilograms, kind of.
	---@field pos Vector Position.
	---@field vel Vector Velocity.
	---@field rot RotMatrix Rotation.
	---@field index integer 🔒 The index of the array in memory this is (0-8191).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field isSettled boolean Whether this rigid body is settled by gravity.
	local RigidBody

	---Create a bond between this body and another at specific local coordinates.
	---@param otherBody RigidBody The second body in the bond.
	---@param thisLocalPos Vector The local position relative to this body.
	---@param otherLocalPos Vector The local position relative to the other body.
	---@return Bond? bond The created bond, if successful.
	function RigidBody:bondTo(otherBody, thisLocalPos, otherLocalPos) end

	---Link rotation between this body and another.
	---Does not seem to be very strong.
	---@param otherBody RigidBody The second body in the bond.
	---@return Bond? bond The created bond, if successful.
	function RigidBody:bondRotTo(otherBody) end

	---Bond a local coordinate of this body to a static point in space.
	---@param localPos Vector The local position relative to this body.
	---@param globalPos Vector The global position in the level.
	---@return Bond? bond The created bond, if successful.
	function RigidBody:bondToLevel(localPos, globalPos) end
end

do
	---Represents a street.
	---@class Street
	---@field class string 🔒 "Street"
	---@field trafficCuboidA Vector The first corner of a cuboid, where points inside are considered to be on the street by traffic AI.
	---@field trafficCuboidB Vector The second corner of a cuboid, where points inside are considered to be on the street by traffic AI.
	---@field numTraffic integer How many AI vehicles are currently on the street.
	---@field index integer 🔒 The index of the array in memory this is.
	---@field name string 🔒 The name of the street, ex. "First Street"
	---@field intersectionA StreetIntersection 🔒 The intersection that the street starts at.
	---@field intersectionB StreetIntersection 🔒 The intersection that the street ends at.
	---@field numLanes integer 🔒 How many lanes the street has.
	local Street = {}

	---Get a lane on the street.
	---@param index integer The index between 0 and numLanes-1.
	---@return StreetLane lane The desired lane.
	function Street:getLane(index) end
end

do
	---Represents a worker thread.
	---@class Worker
	Worker = {}

	---Create a new Worker.
	---@return Worker worker The created Worker.
	function Worker.new() end

	---Start working using a given lua file path.
	---@param fileName string The path to a lua file to execute on the worker thread.
	function Worker:start(fileName) end

	---Indicate that the worker should stop what it's doing.
	---The next time `sleep(ms: integer) -> boolean` is called in the worker thread, true will be returned.
	---It's the code in the worker thread's responsibility to finish all of its procedures.
	function Worker:stop() end

	---Send a message to the worker thread.
	---Adds to a queue such that when `receiveMessage() -> string?` is called in the worker thread, this message can be returned.
	---@param message string The message to send to the worker thread.
	function Worker:sendMessage(message) end

	---Pop a message from the queue of messages received from the worker thread.
	---@return string? message The oldest remaining message received from the worker thread, or nil if none are left.
	function Worker:receiveMessage() end
end

do
	---Represents a child process.
	---@class ChildProcess
	ChildProcess = {}

	---Create a new ChildProcess.
	---@param fileName string The path to a lua file to execute in the child process.
	---@return ChildProcess childProcess The created ChildProcess.
	function ChildProcess.new(fileName) end

	---Check if the child process is currently running.
	---@return boolean isRunning Whether the child process is running.
	function ChildProcess:isRunning() end

	---Terminate the child process.
	---Sends SIGTERM.
	function ChildProcess:terminate() end

	---Get the exit code of the process.
	---@return integer? exitCode The exit code of the child process, or nil if it has not exited.
	function ChildProcess:getExitCode() end

	---Send a message to the child process.
	---Adds to a queue such that when `receiveMessage() -> string?` is called in the child process, this message can be returned.
	---@param message string The message to send to the child process.
	function ChildProcess:sendMessage(message) end

	---Pop a message from the queue of messages received from the child process.
	---@return string? message The oldest remaining message received from the child process, or nil if none are left.
	function ChildProcess:receiveMessage() end

	---Set CPU limits of the child process.
	---@param softLimit integer The soft limit, in seconds.
	---@param hardLimit integer The hard limit, in seconds. May not have permission to increase once initially set.
	function ChildProcess:setCPULimit(softLimit, hardLimit) end

	---Set memory limits of the child process.
	---@param softLimit integer The soft limit, in bytes.
	---@param hardLimit integer The hard limit, in bytes. May not have permission to increase once initially set.
	function ChildProcess:setMemoryLimit(softLimit, hardLimit) end

	---Set maximum file size writing limits of the child process.
	---@param softLimit integer The soft limit, in bytes.
	---@param hardLimit integer The hard limit, in bytes. May not have permission to increase once initially set.
	function ChildProcess:setFileSizeLimit(softLimit, hardLimit) end

	---Get the priority (nice value) of the child process.
	---@return integer priority The priority of the child process.
	function ChildProcess:getPriority() end

	---Set the priority (nice value) of the child process.
	---@param priority integer The new priority of the child process.
	function ChildProcess:setPriority(priority) end
end

do
	---Represents a raster image.
	---@class Image
	---@field width integer 🔒 The width in pixels.
	---@field height integer 🔒 The height in pixels.
	---@field numChannels integer 🔒 The number of channels, typically 3 or 4.
	Image = {}

	---Create a new Image.
	---@return Image image The created Image.
	function Image.new() end

	---Free the image data.
	---This is automatically done whenever an image is garbage collected,
	---but it's still better to call it explicitly when you're done reading.
	function Image:free() end

	---Load an image from a file.
	---Many file formats are supported.
	---@param filePath string The path to the image file to load.
	function Image:loadFromFile(filePath) end

	---Get the RGB pixel color at a given coordinate.
	---Coordinate (0, 0) is the top left of the image.
	---@param x integer The X pixel coordinate.
	---@param y integer The Y pixel coordinate.
	---@return integer red The value of the red channel (0-255).
	---@return integer green The value of the green channel (0-255).
	---@return integer blue The value of the blue channel (0-255).
	function Image:getRGB(x, y) end

	---Get the RGBA pixel color at a given coordinate.
	---Coordinate (0, 0) is the top left of the image.
	---@param x integer The X pixel coordinate.
	---@param y integer The Y pixel coordinate.
	---@return integer red The value of the red channel (0-255).
	---@return integer green The value of the green channel (0-255).
	---@return integer blue The value of the blue channel (0-255).
	---@return integer alpha The value of the alpha channel (0-255).
	function Image:getRGBA(x, y) end
end

---Represents an active client network connection.
---@class Connection
---@field class string 🔒 "Connection"
---@field port integer
---@field timeoutTime integer How many ticks the connection has not responded, will be deleted after 30 seconds.
---@field address string 🔒 IPv4 address ("x.x.x.x")
---@field adminVisible boolean Whether this connection is sent admin only events (admin messages).

---Represents a persistent player account stored on the server.
---@class Account
---@field class string 🔒 "Account"
---@field subRosaID integer Unique account index given by the master server, should not be used.
---@field phoneNumber integer Unique public ID tied to the account, ex. 2560001
---@field money integer
---@field corporateRating integer
---@field criminalRating integer
---@field spawnTimer integer How long this person has to wait to spawn in, in seconds.
---@field playTime integer How many world mode minutes this person has played for.
---@field banTime integer Remaining ban time in minutes.
---@field index integer 🔒 The index of the array in memory this is (0-255).
---@field name string 🔒 Last known player name.
---@field steamID string 🔒 SteamID64

---Represents a type of item that exists.
---@class ItemType
---@field class string 🔒 "ItemType"
---@field price integer How much money is taken when bought. Not networked.
---@field mass number In kilograms, kind of.
---@field fireRate integer How many ticks between two shots.
---@field bulletType integer
---@field bulletVelocity number
---@field bulletSpread number
---@field numHands integer
---@field rightHandPos Vector
---@field leftHandPos Vector
---@field boundsCenter Vector
---@field index integer 🔒 The index of the array in memory this is.
---@field name string Not networked.
---@field isGun boolean

---Represents a bullet currently flying through the air.
---@class Bullet
---@field class string 🔒 "Bullet"
---@field type integer
---@field time integer How many ticks this bullet has left until it despawns.
---@field lastPos Vector Where the bullet was last tick.
---@field pos Vector Position.
---@field vel Vector Velocity.
---@field player Player? Who shot this bullet.

---Represents a bone in a human.
---@class Bone
---@field class string 🔒 "Bone"
---@field pos Vector Position.
---@field pos2 Vector Second position.

---Represents a bond between one or two rigid bodies.
---@class Bond
---@field class string 🔒 "Bond"
---@field type integer
---@field despawnTime integer How many ticks until removal, 65536 for never.
---@field globalPos Vector
---@field localPos Vector
---@field otherLocalPos Vector
---@field index integer 🔒 The index of the array in memory this is (0-16383).
---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
---@field body RigidBody The rigid body of this bond.
---@field otherBody RigidBody The second rigid body of this bond, if there is one.

---Represents a networked action sent from a player.
---@class Action
---@field class string 🔒 "Action"
---@field type integer
---@field a integer
---@field b integer
---@field c integer
---@field d integer

---Represents a button in the world base menu.
---@class MenuButton
---@field class string 🔒 "MenuButton"
---@field id integer The ID of the button.
---@field text string The text displayed on the button.

---Represents a lane on a street.
---@class StreetLane
---@field class string 🔒 "StreetLane"
---@field direction integer The direction of the lane, either 0 or 1.
---@field posA Vector The first point in the lane path.
---@field posB Vector The second point in the lane path.

---Represents an intersection of one or more streets.
---@class StreetIntersection
---@field class string 🔒 "StreetIntersection"
---@field pos Vector The centre point of the intersection.
---@field lightsState integer A number used internally by the traffic AI, which changes when the timer resets.
---@field lightsTimer integer A timer used internally by the traffic AI, which increments every tick until it reaches lightsTimerMax.
---@field lightsTimerMax integer The maximum value of the traffic timer before it resets.
---@field lightEast integer The colour of the east light. 0 = red, 1 = yellow, 2 = green.
---@field lightSouth integer The colour of the south light. 0 = red, 1 = yellow, 2 = green.
---@field lightWest integer The colour of the west light. 0 = red, 1 = yellow, 2 = green.
---@field lightNorth integer The colour of the north light. 0 = red, 1 = yellow, 2 = green.
---@field index integer 🔒 The index of the array in memory this is.
---@field streetEast Street? 🔒 The street connected to the east, if any.
---@field streetSouth Street? 🔒 The street connected to the south, if any.
---@field streetWest Street? 🔒 The street connected to the west, if any.
---@field streetNorth Street? 🔒 The street connected to the north, if any.