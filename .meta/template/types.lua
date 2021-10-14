do
	---Represents the server; only one instance in the global variable `server`.
	---@class Server
	---@field class string 🔒 "Server"
	---@field TPS integer 🔒 How many ticks are in 1 second according to in-game timers (60).
	---@field port integer 🔒
	---@field name string Name shown on the server list, max length of 31.
	---@field adminPassword string The admin password used in the /admin command.
	---@field password string Empty string for no password, otherwise people will need to type this to join.
	---@field maxPlayers integer
	---@field maxBytesPerSecond integer
	---@field worldTraffic integer How many traffic cars there should be in world mode.
	---@field worldStartCash integer
	---@field worldMinCash integer
	---@field worldShowJoinExit boolean
	---@field worldRespawnTeam boolean
	---@field worldCrimeCivCiv integer
	---@field worldCrimeCivTeam integer
	---@field worldCrimeTeamCiv integer
	---@field worldCrimeTeamTeam integer
	---@field worldCrimeTeamTeamInBase integer
	---@field worldCrimeNoSpawn integer
	---@field roundRoundTime integer How long rounds are in round mode, in minutes.
	---@field roundStartCash integer
	---@field roundIsWeekly boolean
	---@field roundHasBonusRatio boolean
	---@field roundTeamDamage integer
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
	---Available in worker threads.
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
	---@return number distance The distance between self and other.
	function Vector:dist(other) end

	---Calculate the distance between self and other, squared.
	---Much faster as it does not square root the value.
	---@param other Vector The vector to calculate distance to.
	---@return number distanceSquared The distance, squared.
	function Vector:distSquare(other) end

	---Calculate the length of the vector.
	---@return number length The length of the vector.
	function Vector:length() end

	---Calculate the length of the vector, squared.
	---Much faster as it does not square root the value.
	---@return number length The length of the vector, squared.
	function Vector:lengthSquare() end

	---Calculate the dot product of self and other.
	---@param other Vector The vector to calculate the dot product with.
	---@return number dotProduct The dot product of self and other.
	function Vector:dot(other) end

	---Get the coordinates of the level block the vector is in.
	---@return integer blockX
	---@return integer blockY
	---@return integer blockZ
	function Vector:getBlockPos() end

	---Normalize the vector's values so that it has a length of 1.
	function Vector:normalize() end
end

do
	---Represents the rotation of an object as a 3x3 matrix.
	---Available in worker threads.
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

	---Get a normal vector pointing in the rotation's +X direction.
	---@return Vector forward The normal vector.
	function RotMatrix:getForward() end

	---Get a normal vector pointing in the rotation's +Y direction.
	---@return Vector up The normal vector.
	function RotMatrix:getUp() end

	---Get a normal vector pointing in the rotation's +Z direction.
	---@return Vector right The normal vector.
	function RotMatrix:getRight() end
end

do
	---Represents a player's transmitting voice chat.
	---@class Voice
	---@field class string 🔒 "Voice"
	---@field volumeLevel integer The volume of the voice. 0 = whisper, 1 = normal, 2 = yell.
	---@field currentFrame integer The current frame being sent, 0-63.
	---@field isSilenced boolean Whether the voice is not transmitting.
	local Voice

	---Get a specific encoded Opus frame.
	---@param index integer The index between 0 and 63.
	---@return string frame The encoded Opus frame.
	function Voice:getFrame(index) end

	---Set a specific encoded Opus frame.
	---@param index integer The index between 0 and 63.
	---@param frame frame The encoded Opus frame.
	---@param volumeLevel integer The volume of the frame. 0 = whisper, 1 = normal, 2 = yell.
	function Voice:setFrame(index, frame, volumeLevel) end
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
	---@field teamMoney integer The value of their team's balance in world mode.
	---@field budget integer The value of their team's budget in world mode.
	---@field corporateRating integer
	---@field criminalRating integer
	---@field team integer 💾
	---@field teamSwitchTimer integer Ticks remaining until they can switch teams again.
	---@field stocks integer 💲 The amount of shares they own in their company.
	---@field spawnTimer integer How long this person has to wait to spawn in, in seconds.
	---@field gearX number Left to right stick shift position, 0 to 2.
	---@field leftRightInput number Left to right movement input, -1 to 1.
	---@field gearY number Forward to back stick shift position, -1 to 1.
	---@field forwardBackInput number Backward to forward movement input, -1 to 1.
	---@field viewPitch number Radians.
	---@field pointYaw number Radians.
	---@field pointPitch number Radians.
	---@field viewYaw number Radians.
	---@field inputFlags integer Bitflags of current buttons being pressed.
	---@field lastInputFlags integer Input flags from the last tick.
	---@field zoomLevel integer 0 = run, 1 = walk, 2 = aim.
	---@field inputType integer What the input fields are used for. 0 = none, 1 = human, 2 = car, 3 = helicopter. Defaults to 0.
	---@field menuTab integer What tab in the menu they are currently in.
	---@field numActions integer
	---@field lastNumActions integer
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
	---@field isZombie boolean 💾 Whether the bot player should always run towards it's target.
	---@field human? Human 💾 The human they currently control.
	---@field connection? Connection 🔒 Their network connection.
	---@field account? Account Their account.
	---@field voice Voice Their voice.
	---@field botDestination? Vector The location this bot will walk towards.
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
	---@return Event event The created event.
	function Player:update() end

	---Fire a network event containing financial info.
	---@return Event event The created event.
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
	---@field inputFlags integer Bitflags of current buttons being pressed.
	---@field lastInputFlags integer Input flags from the last tick.
	---@field health integer Dynamic health, 0-100.
	---@field bloodLevel integer How much blood they have, 0-100. <50 and they will collapse.
	---@field chestHP integer Dynamic chest health, 0-100.
	---@field headHP integer
	---@field leftArmHP integer
	---@field rightArmHP integer
	---@field leftLegHP integer
	---@field rightLegHP integer
	---@field progressBar integer Progress bar displayed in the center of the screen, 0-255. 0 = disabled.
	---@field inventoryAnimationFlags integer 
	---@field inventoryAnimationProgress integer 
	---@field inventoryAnimationDuration number 
	---@field inventoryAnimationHand integer 
	---@field inventoryAnimationSlot integer 
	---@field inventoryAnimationCounter integer 
	---@field inventoryAnimationCounterFinished integer 
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
	---@field lastUpdatedWantedGroup integer 0 = white, 1 = yellow, 2 = red. Change to a different value (ex. -1) to re-network appearance fields (model, gender, etc.)
	---@field index integer 🔒 The index of the array in memory this is (0-255).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field isAlive boolean
	---@field isImmortal boolean Whether they are immune to bullet and physics damage.
	---@field isOnGround boolean 🔒
	---@field isStanding boolean 🔒
	---@field isBleeding boolean
	---@field player? Player The player controlling this human.
	---@field account? Account The disconnected account that owns this human.
	---@field vehicle? Vehicle The vehicle they are inside.
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

	---Get a specific inventory slot.
	---@param index integer The index between 0 and 6.
	---@return InventorySlot inventorySlot The desired inventory slot.
	function Human:getInventorySlot(index) end

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
	---Represents a type of item that exists.
	---@class ItemType
	---@field class string 🔒 "ItemType"
	---@field price integer How much money is taken when bought. Not networked.
	---@field mass number In kilograms, kind of.
	---@field fireRate integer How many ticks between two shots.
	---@field magazineAmmo integer
	---@field bulletType integer
	---@field bulletVelocity number
	---@field bulletSpread number
	---@field numHands integer
	---@field rightHandPos Vector
	---@field leftHandPos Vector
	---@field primaryGripStiffness number
	---@field primaryGripRotation number In radians.
	---@field secondaryGripStiffness number
	---@field secondaryGripRotation number In radians.
	---@field gunHoldingPos Vector The offset of where the item is held if it is a gun.
	---@field boundsCenter Vector
	---@field index integer 🔒 The index of the array in memory this is.
	---@field name string Not networked.
	---@field isGun boolean
	local ItemType

	---Get whether this type can be mounted to another type.
	---@param parent ItemType
	---@return boolean canMount
	function ItemType:getCanMountTo(parent) end

	---Set whether this type can be mounted to another type.
	---@param parent ItemType
	---@param canMount boolean
	function ItemType:setCanMountTo(parent, canMount) end
end

do
	---Represents an item in the world or someone's inventory.
	---💾 = To network changed value to clients, the `update` method needs to be called.
	---@class Item
	---@field class string 🔒 "Item"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field type ItemType 💾
	---@field despawnTime integer Ticks remaining until removal.
	---@field parentSlot integer The slot this item occupies if it has a parent.
	---@field parentHuman? Human The human this item is mounted to, if any.
	---@field parentItem? Item The item this item is mounted to, if any.
	---@field pos Vector Position.
	---@field vel Vector Velocity.
	---@field rot RotMatrix Rotation.
	---@field bullets integer How many bullets are inside this item.
	---@field cooldown integer
	---@field cashSpread integer
	---@field cashAmount integer
	---@field cashPureValue integer
	---@field computerCurrentLine integer
	---@field computerTopLine integer Which line is at the top of the screen.
	---@field computerCursor integer The location of the cursor, -1 for no cursor.
	---@field index integer 🔒 The index of the array in memory this is (0-1023).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field hasPhysics boolean Whether this item is currently physically simulated.
	---@field physicsSettled boolean Whether this item is settled by gravity.
	---@field physicsSettledTimer integer How many ticks the item has been settling. Once it has reached 60, it will be settled.
	---@field isStatic boolean Whether the item is immovable.
	---@field rigidBody RigidBody The rigid body representing the physics of this item.
	---@field vehicle? Vehicle The vehicle which this item is a key for.
	---@field grenadePrimer? Player The player who primed this grenade.
	---@field phoneTexture integer 💾 The phone's texture ID. 0 for white, 1 for black.
	---@field phoneNumber integer The number used to call this phone.
	---@field displayPhoneNumber integer 💾 The number currently displayed on the phone.
	---@field enteredPhoneNumber integer The number that has been entered on the phone. Will reset upon reaching 4 digits.
	---@field connectedPhone? Item The phone that this phone is connected to.
	local Item

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

	---Increment the current line of a computer.
	---Only works if this item is a computer.
	function Item:computerIncrementLine() end

	---Set the text to display on a line. Does not immediately network.
	---Only works if this item is a computer.
	---@param lineIndex integer Which line to edit.
	---@param text string The text to set the line to. Max 63 characters.
	function Item:computerSetLine(lineIndex, text) end

	---Set the colors to display on a line. Does not immediately network.
	---Only works if this item is a computer.
	---@param lineIndex integer Which line to edit.
	---@param colors string The colors to set the line to, where every character represents a color value from 0x00 to 0xFF. Max 63 characters.
	function Item:computerSetLineColors(lineIndex, colors) end

	---Set the color of a character on screen. Does not immediately network.
	---Only works if this item is a computer.
	---Uses the 16 CGA colors for foreground and background separately.
	---@param lineIndex integer Which line to edit.
	---@param columnIndex integer Which column to edit.
	---@param color integer The color to set, between 0x00 and 0xFF.
	function Item:computerSetColor(lineIndex, columnIndex, color) end

	---Add a bank bill to the stack of cash.
	---Only works if this item is a stack of cash.
	---@param position integer The relative position on the stack to add the bill, in no particular range.
	---@param value integer The denomination type of the bill (0-7).
	function Item:cashAddBill(position, value) end

	---Remove a bank bill from the stack of cash.
	---Only works if this item is a stack of cash.
	---@param position integer The relative position on the stack to find the bill to remove, in no particular range.
	function Item:cashRemoveBill(position) end

	---Get the total value of the stack of cash.
	---Only works if this item is a stack of cash.
	---@return integer value The total value in dollars.
	function Item:cashGetBillValue() end
end

do
	---Represents a car, train, or helicopter.
	---💾 = To network changed value to clients, the `updateType` method needs to be called.
	---@class Vehicle
	---@field class string 🔒 "Vehicle"
	---@field data table A Lua table which persists throughout the lifespan of this object.
	---@field type VehicleType 💾
	---@field isLocked boolean Whether or not this has a key and is locked.
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
	---@field engineRPM integer The RPM of the engine to be networked, 0 to 8191.
	---@field numSeats integer The number of accessible seats.
	---@field index integer 🔒 The index of the array in memory this is (0-511).
	---@field isActive boolean Whether or not this exists, only change if you know what you are doing.
	---@field lastDriver? Player 🔒 The last person to drive the vehicle.
	---@field rigidBody RigidBody 🔒 The rigid body representing the physics of this vehicle.
	---@field trafficCar? TrafficCar The traffic car the vehicle belongs to.
	local Vehicle

	---Fire a network event containing basic info.
	---@return Event event The created event.
	function Vehicle:updateType() end

	---Fire a network event to make a part appear to break.
	---Also used to visually toggle train doors.
	---@param kind integer The kind of part. 0 = window, 1 = tire, 2 = entire body, 6 = repair window.
	---@param position Vector The global position of the destruction.
	---@param normal Vector The normal of the destruction.
	---@return Event event The created event.
	function Vehicle:updateDestruction(kind, partIndex, position, normal) end

	---Remove self safely and fire a network event.
	function Vehicle:remove() end

	---Get whether a specific window is broken.
	---@param index integer The index between 0 and 7.
	---@return boolean isWindowBroken
	function Vehicle:getIsWindowBroken(index) end

	---Set whether a specific window is broken.
	---@param index integer The index between 0 and 7.
	---@param isWindowBroken boolean
	function Vehicle:setIsWindowBroken(index, isWindowBroken) end
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
	---@field rotVel RotMatrix Rotational velocity.
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

	---Collide with the level for one tick.
	---@param localPos Vector The local position relative to this body.
	---@param normal Vector The normal of the collision.
	---@param a number
	---@param b number
	---@param c number
	---@param d number
	function RigidBody:collideLevel(localPos, normal, a, b, c, d) end
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
	local Street

	---Get a lane on the street.
	---@param index integer The index between 0 and numLanes-1.
	---@return StreetLane lane The desired lane.
	function Street:getLane(index) end
end

do
	---Represents a special building.
	---@class Building
	---@field class string 🔒 "Building"
	---@field type integer The type of building. 1 = base, 3 = car shop, 4 = laboratory, 5 = cosmetics shop, 6 = bank, 8 = gun shop, 9 = burger shop.
	---@field pos Vector The origin point of the building. May not be inside.
	---@field spawnRot RotMatrix The rotation which this building spawns things (players in a base, cars in a car shop, etc.)
	---@field interiorCuboidA Vector The first corner of a cuboid, where the interior of the building is contained inside.
	---@field interiorCuboidB Vector The second corner of a cuboid, where the interior of the building is contained inside.
	---@field numShopCars integer How many cars are for sale at this car shop.
	---@field shopCarSales integer How many cars have been sold at this car shop.
	---@field index integer 🔒 The index of the array in memory this is.
	local Building

	---Get a car slot at this car shop.
	---@param index integer The index between 0 and 15.
	---@return ShopCar shopCar The desired shop car.
	function Building:getShopCar(index) end
end

do
	---Represents an active client network connection.
	---Connections can be moved around in memory every tick, so don't hold onto references.
	---@class Connection
	---@field class string 🔒 "Connection"
	---@field port integer
	---@field timeoutTime integer How many ticks the connection has not responded, will be deleted after 30 seconds.
	---@field address string 🔒 IPv4 address ("x.x.x.x")
	---@field adminVisible boolean Whether this connection is sent admin only events (admin messages).
	---@field player? Player The connected player.
	---@field spectatingHuman? Human The human this connection is currently spectating, if any.
	local Connection

	---Get a specific voice earshot.
	---@param index integer The index between 0 and 7.
	---@return EarShot earShot The desired earshot.
	function Connection:getEarShot(index) end

	---Check whether or not the connection has received an event, at which point the event won't be transmitted to them anymore.
	---@param event Event The event to compare.
	---@return boolean
	function Connection:hasReceivedEvent(event) end
end

do
	---Represents a worker thread.
	---@class Worker
	Worker = {}

	---Create a new Worker using a given lua file path.
	---@param fileName string The path to a lua file to execute on the worker thread.
	---@return Worker worker The created Worker.
	function Worker.new(fileName) end

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
	---Available in worker threads.
	---@class Image
	---@field width integer 🔒 The width in pixels.
	---@field height integer 🔒 The height in pixels.
	---@field numChannels integer 🔒 The number of channels, typically 3 or 4.
	Image = {}

	---Create a new Image.
	---@return Image image The created Image.
	function Image.new() end

	---Free the image data.
	---This is automatically done whenever an Image is garbage collected,
	---but it's still better to call it explicitly when you're done reading.
	function Image:free() end

	---Load an image from a file.
	---Many file formats are supported.
	---@param filePath string The path to the image file to load.
	function Image:loadFromFile(filePath) end

	---Load a blank image with desired dimensions.
	---@param width integer How wide the image should be.
	---@param height integer How tall the image should be.
	---@param numChannels integer How many channels the image should have (1-4).
	function Image:loadBlank(width, height, numChannels) end

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

	---Set the color of a pixel.
	---@param x integer The X pixel coordinate.
	---@param y integer The Y pixel coordinate.
	---@param red integer The red channel value.
	---@param green integer The green channel value.
	---@param blue integer The blue channel value.
	function Image:setPixel(x, y, red, green, blue) end
	---@param x integer The X pixel coordinate.
	---@param y integer The Y pixel coordinate.
	---@param red integer The red channel value.
	---@param green integer The green channel value.
	---@param blue integer The blue channel value.
	---@param alpha integer The alpha channel value.
	function Image:setPixel(x, y, red, green, blue, alpha) end

	---Get the PNG representation of an image.
	---@return string png The buffer of a PNG file representing the image.
	function Image:getPNG() end
end

do
	---A connection to an SQLite 3 database.
	---Available in worker threads.
	---@class SQLite
	SQLite = {}

	---Create a new SQLite using a given database file path.
	---@param fileName string The path to a database file to connect to. If ':memory:', this will be a temporary in-memory database. If an empty string, this will be a temporary on-disk database.
	---@return SQLite db The created SQLite.
	function SQLite.new(fileName) end

	---Close the database.
	---This is automatically done whenever an SQLite is garbage collected,
	---but it's still better to call it explicitly when you're done using it.
	function SQLite:close() end

	---Execute an SQL query.
	---@param sql string The SQL string to execute.
	---@vararg nil|string|number|boolean The optional arguments if this is a parameterized query.
	---@return integer|table[] result The number of changes or the returned rows, if the query generates any, where each row is a table of columns. Values can be `nil`, `string`, or `number`.
	---@return string? err The error from preparing/running the query, if there was one.
	function SQLite:query(sql, ...) end
end

do
	---An object which can listen for file system events.
	---Available in worker threads.
	---@class FileWatcher
	FileWatcher = {}

	---Create a new FileWatcher.
	---@return FileWatcher fileWatcher The created FileWatcher.
	function FileWatcher.new() end

	---Add a new directory/file to watch.
	---@param path string The path to watch.
	---@param mask integer The flags for the watch. See FILE_WATCH_* constants.
	function FileWatcher:addWatch(path, mask) end

	---Remove a watch if it exists.
	---@param path string The path to remove.
	---@return boolean success Whether the path was an existing watch.
	function FileWatcher:removeWatch(path) end

	---@class FileWatchEvent
	---@field descriptor string The path of the watch the event was for.
	---@field mask integer The flags for the event. See FILE_WATCH_* constants.
	---@field name string The name of the directory/file where the event took place.

	---Read the next event.
	---@return FileWatchEvent? event The next event, or nil if there was no event.
	function FileWatcher:receiveEvent() end
end

do
	---An Opus audio encoder.
	---Available in worker threads.
	---@class OpusEncoder
	---@field bitRate integer The bit rate used when encoding audio, in bits/second.
	OpusEncoder = {}

	---Create a new OpusEncoder.
	---@return OpusEncoder encoder The created OpusEncoder.
	function OpusEncoder.new() end

	---Close the opened file, if there is any.
	---This is automatically done whenever an OpusEncoder is garbage collected,
	---but it's still better to call it explicitly when you're done encoding.
	function OpusEncoder:close() end

	---Open a file for encoding. Closes any previously opened file.
	---Throws if the file cannot be opened.
	---@param fileName string The path to a 48000Hz signed 16-bit raw PCM file to use for encoding.
	function OpusEncoder:open(fileName) end

	---Rewind the opened file to the beginning.
	function OpusEncoder:rewind() end

	---Encode a single 20ms Opus frame.
	---Throws if the file is not opened, or there is a problem when reading or encoding.
	---@return frame? string The next encoded frame, or nil if there is nothing left to read.
	function OpusEncoder:encodeFrame() end

	---Encode a single 20ms Opus frame.
	---Throws if input is the wrong length, or there is a problem when encoding.
	---@param input string The raw PCM bytes, which contains either 960 32-bit floats or 960 16-bit signed integers.
	---@return frame string The encoded frame.
	function OpusEncoder:encodeFrame(input) end
end

do
	---A graph of nodes representing points in space.
	---Available in worker threads.
	---@class PointGraph
	PointGraph = {}

	---Get the number of nodes in the graph.
	---@return integer size The number of nodes in the graph.
	function PointGraph:getSize() end

	---Add a node.
	---@param x integer The x coordinate of the node in space used when finding paths.
	---@param y integer The y coordinate of the node in space used when finding paths.
	---@param z integer The z coordinate of the node in space used when finding paths.
	function PointGraph:addNode(x, y, z) end

	---Get the coordinates of a node by its index.
	---@param index integer The index of the node.
	---@return integer x
	---@return integer y
	---@return integer z
	function PointGraph:getNodePoint(index) end

	---Add a unidirected link from one node to another.
	---@param fromIndex integer The index of the start node.
	---@param toIndex integer The index of the end node.
	---@param cost integer The cost of the link used when finding paths, typically corresponding to distance.
	function PointGraph:addLink(fromIndex, toIndex, cost) end

	---Get the index of a node by its coordinates.
	---Runs in O(1) time.
	---@param x integer
	---@param y integer
	---@param z integer
	---@return integer? index The index of the node, or nil if there isn't one at those coordinates.
	function PointGraph:getNodeByPoint(x, y, z) end

	---Find the shortest path from a start node to an end node.
	---Uses the A* algorithm.
	---@param startIndex integer The index of the starting node.
	---@param endIndex integer The index of the end/goal node.
	---@return integer[]? path The list of node indices of the shortest path, or nil if no path was found.
	function PointGraph:findShortestPath(startIndex, endIndex) end
end

---Represents a real number used in hooks whose value can be changed before its parent is called.
---@class HookFloat
---@field value number The underlying float value.

---Represents a 32-bit integer used in hooks whose value can be changed before its parent is called.
---@class HookInteger
---@field value integer The underlying int value.

---Represents a 32-bit unsigned integer used in hooks whose value can be changed before its parent is called.
---@class HookUnsignedInteger
---@field value integer The underlying unsigned int value.

---Represents a persistent player account stored on the server.
---@class Account
---@field class string 🔒 "Account"
---@field data table A Lua table which persists throughout the duration of the server.
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

---Represents a type of vehicle that exists.
---@class VehicleType
---@field class string 🔒 "VehicleType"
---@field usesExternalModel boolean
---@field controllableState integer 0 = cannot be controlled, 1 = car, 2 = helicopter.
---@field index integer 🔒 The index of the array in memory this is.
---@field name string Not networked.
---@field price integer How much money is taken when bought.
---@field mass number In kilograms, kind of.

---Represents a bullet currently flying through the air.
---Bullets can be moved around in memory every tick, so don't hold onto references.
---@class Bullet
---@field class string 🔒 "Bullet"
---@field type integer
---@field time integer How many ticks this bullet has left until it despawns.
---@field lastPos Vector Where the bullet was last tick.
---@field pos Vector Position.
---@field vel Vector Velocity.
---@field player? Player Who shot this bullet.

---Represents a bone in a human.
---@class Bone
---@field class string 🔒 "Bone"
---@field pos Vector Position.
---@field pos2 Vector Second position.

---@class InventorySlot
---@field class string 🔒 "InventorySlot"
---@field primaryItem? Item 🔒 The first item in the slot, if any.
---@field secondaryItem? Item 🔒 The second item in the slot, if any.

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
---@field streetEast? Street 🔒 The street connected to the east, if any.
---@field streetSouth? Street 🔒 The street connected to the south, if any.
---@field streetWest? Street 🔒 The street connected to the west, if any.
---@field streetNorth? Street 🔒 The street connected to the north, if any.

---@class TrafficCar
---@field class string 🔒 "TrafficCar"
---@field index integer 🔒 The index of the array in memory this is.
---@field type VehicleType The type of the car.
---@field human? Human The human driving the car.
---@field isBot boolean
---@field isAggressive boolean
---@field vehicle? Vehicle The real vehicle used by the car.
---@field pos Vector Position.
---@field vel Vector Velocity.
---@field yaw number Radians.
---@field rot RotMatrix Rotation.
---@field color integer The color of the car.
---@field state integer

---Represents a car for sale at a car shop.
---@class ShopCar
---@field class string 🔒 "ShopCar"
---@field price integer How much money is taken when bought. Note that if the key is sold, the price of the VehicleType is used for refunds.
---@field color integer The color of the car.
---@field type VehicleType The type of the car.

---Represents a state of someone being able to hear another person's voice chat.
---@class EarShot
---@field class string 🔒 "EarShot"
---@field isActive boolean Whether or not this exists.
---@field player? Player The player that the voice is coming from.
---@field human? Human The human that the voice appears to come from.
---@field receivingItem? Item The item that the voice appears to come from.
---@field transmittingItem? Item The item that the other person is using to transmit their voice.
---@field distance number The distance of the voice.
---@field volume number The estimated volume of the voice, 0 to 1.

---Represents an occurrence that is synchronized to all connections.
---@class Event
---@field class string 🔒 "Event"
---@field index integer 🔒 The index of the array in memory this is.
---@field type integer The type of the event. Different types use different data fields.
---@field tickCreated integer The number of ticks since the last game reset at which the event was created.
---@field vectorA Vector
---@field vectorB Vector
---@field a integer
---@field b integer
---@field c integer
---@field d integer
---@field floatA number
---@field floatB number
---@field message string Max length of 63.
