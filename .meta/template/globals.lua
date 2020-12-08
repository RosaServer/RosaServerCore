bit32 = bit

---Indicates a call when the server first starts up.
RESET_REASON_BOOT = 0
---Indicates a call by the engine, usually when the round/day resets in default game modes.
RESET_REASON_ENGINECALL = 1
---Indicates a call after the Lua state was manually reset.
RESET_REASON_LUARESET = 2
---Indicates a call from Server:reset.
RESET_REASON_LUACALL = 3

---In round-based modes, the player list screen is shown in this state to those who aren't spawned in.
STATE_PREGAME = 1
---Game is ongoing. In round-based modes, players not spawned in will spectate. World players can spawn as they please.
STATE_GAME = 2
---Used in round-based modes when the game is over and the player list is shown before reset.
STATE_RESTARTING = 3

---Driving mode.
---@deprecated
TYPE_DRIVING = 1
---Racing mode.
---@deprecated
TYPE_RACE = 2
---Round mode.
TYPE_ROUND = 3
---World mode.
TYPE_WORLD = 4
---Eliminator mode.
TYPE_TERMINATOR = 5
---Co-op mode.
TYPE_COOP = 6
---Versus mode.
TYPE_VERSUS = 7

---The hook library which hooked events will call upon.
---The hook.run function must be defined to use hooks.
hook = {
	persistentMode = ''
}

---Recreate the Lua state completely at the start of the next logic tick.
---Runs lua/main.lua again after reset.
---@param mode string The string to set to hook.persistentMode in the new state.
function flagStateForReset(mode) end

---Create a new Vector with 0 for every coordinate.
---@return Vector vector The created vector.
function Vector() end

---Create a new Vector with given coordinates.
---@param x number
---@param y number
---@param z number
---@return Vector vector The created vector.
function Vector(x, y, z) end

---Create a new RotMatrix.
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@param x3 number
---@param y3 number
---@param z3 number
---@return RotMatrix rotMatrix The created rotation matrix.
function RotMatrix(
	x1, y1, z1,
	x2, y2, z2,
	x3, y3, z3
) end

---Library for sending HTTP(S) requests.
http = {}

---@class HTTPResponse
---@field status integer The HTTP status code.
---@field body string The response body.
---@field headers table<string, string> The response headers.

---Send an HTTP(S) GET request synchronously.
---Not recommended to use this on the main thread.
---@param scheme string The hostname of the server to send the request to, with optional protocol and port. Ex. google.com, https://google.com, https://google.com:443
---@param path string The path to request from the server.
---@param headers table<string, string> The table of request headers.
---@return HTTPResponse? response
function http.getSync(scheme, path, headers) end

---Send an HTTP(S) POST request synchronously.
---Not recommended to use this on the main thread.
---@param scheme string The hostname of the server to send the request to, with optional protocol and port. Ex. google.com, https://google.com, https://google.com:443
---@param path string The path to request from the server.
---@param headers table<string, string> The table of request headers.
---@param body string The request body.
---@param contentType string The request body MIME type.
---@return HTTPResponse? response
function http.postSync(scheme, path, headers, body, contentType) end

---Library for creating networked events.
event = {}

---Play a sound.
---@param soundType integer The type of the sound.
---@param position Vector The position of the sound.
---@param volume number The volume of the sound, where 1.0 is standard.
---@param pitch number The pitch of the sound, where 1.0 is standard.
function event.sound(soundType, position, volume, pitch) end

---Play a sound.
---@param soundType integer The type of the sound.
---@param position Vector The position of the sound.
function event.sound(soundType, position) end

---Display a grenade explosion.
---@param position Vector The position to show the explosion at.
function event.explosion(position) end

---Indicate a bullet has hit a person or thing.
---@param hitType integer The type of hit. 0 = bullet hole (stays until round reset), 1 = human hit (blood), 2 = car hit (metal), 3 = blood drip (bleeding).
---@param position Vector The position the bullet hit.
---@param normal Vector The normal of the surface the bullet hit.
function event.bulletHit(hitType, position, normal) end

---Library for using generic physics functions of the engine.
physics = {}

---@class LineIntersectResult
---@field hit boolean Whether it hit. If false, all other fields will be nil.
---@field pos Vector? The global position where the ray hit.
---@field normal Vector? The normal of the surface the ray hit.
---@field fraction number? How far along the ray the hit was (0.0 - 1.0).
---@field bone integer? Which bone the ray hit, if it was cast on a human.
---@field face integer? Which face the ray hit, if not a wheel, if it was cast on a vehicle.
---@field wheel integer? Which wheel the ray hit, if not a face, if it was cast on a vehicle.

---Cast a ray in the level and find where it hits.
---@param posA Vector The start point of the ray.
---@param posB Vector The end point of the ray.
---@return LineIntersectResult result The result of the intersection.
function physics.lineIntersectLevel(posA, posB) end

---Cast a ray on a single human.
---@param human Human The human to cast the ray on.
---@param posA Vector The start point of the ray.
---@param posB Vector The end point of the ray.
---@return LineIntersectResult result The result of the intersection.
function physics.lineIntersectHuman(human, posA, posB) end

---Cast a ray on a single vehicle.
---@param vehicle Vehicle The vehicle to cast the ray on.
---@param posA Vector The start point of the ray.
---@param posB Vector The end point of the ray.
---@return LineIntersectResult result The result of the intersection.
function physics.lineIntersectVehicle(vehicle, posA, posB) end

---Cast a ray on an arbitrary triangle.
---The vertices of the triangle must be clockwise relative to the normal.
---The vector passed to outPosition will be modified by the function.
---@param outPosition Vector A vector whose values will be set to the position the ray hit.
---@param normal Vector The normal of the triangle.
---@param posA Vector The start point of the ray.
---@param posB Vector The end point of the ray.
---@param triA Vector The first vertex of the triangle.
---@param triB Vector The second vertex of the triangle.
---@param triC Vector The third vertex of the triangle.
---@return number? fraction How far along the ray hit was (0.0 - 1.0). Nil if it did not hit.
function physics.lineIntersectTriangle(outPosition, normal, posA, posB, triA, triB, triC) end

---Remove all bullets that have no time remaining.
---May shift bullets in memory if any are removed.
function physics.garbageCollectBullets() end

---Library for sending chat messages.
chat = {}

---Display a message in the chat box to everybody.
---@param message string The message to send. Max length 63.
function chat.announce(message) end

---Display a message in the chat box only to admins.
---More specifically, all players whose connection has `adminVisible` set to true.
---@param message string The message to send. Max length 63.
function chat.tellAdmins(message) end

---Add a message to chat using the engine's expected values.
---@param speakerType integer The type of message. 0 = dead chat, 1 = human speaking, 2 = item speaking, 3 = MOTD, 4 = to admins, 5 = billboard, 6 = to player.
---@param message string The message to send. Max length 63.
---@param speakerIndex integer The index of the speaker object of the corresponding type, if applicable, or -1.
---@param volumeLevel integer The volume to speak at. 0 = whisper, 1 = normal, 2 = yell.
---@deprecated
function chat.addRaw(speakerType, message, speakerIndex, volumeLevel) end

---Library for managing Account objects.
---accounts[index: integer] -> Account
accounts = {}

---Save all accounts to the `server.srk` file.
function accounts.save() end

---Get all accounts.
---@return Account[] accounts A list of all Account objects.
function accounts.getAll() end

---Get the number of accounts.
---@return integer count How many Account objects there are.
function accounts.getCount() end

---Find an account by phone number.
---@param phoneNumber integer The phone identifier to search for.
---@return Account? account The found account, or nil.
function accounts.getByPhone(phoneNumber) end

---Library for managing Player objects.
---players[index: integer] -> Player
players = {}

---Get all players.
---@return Player[] players A list of all Player objects.
function players.getAll() end

---Get the number of players.
---@return integer count How many Player objects there are.
function players.getCount() end

---Find a player by phone number.
---@param phoneNumber integer The phone identifier to search for.
---@return Player? player The found player, or nil.
function players.getByPhone(phoneNumber) end

---Get all players, excluding bots.
---@return Player[] players A list of all Player objects, excluding bots.
function players.getNonBots() end

---Create a new bot player.
---@return Player? bot The created bot player, or nil on failure.
function players.createBot() end

---Library for managing Human objects.
---humans[index: integer] -> Human
humans = {}

---Get all humans.
---@return Human[] humans A list of all Human objects.
function humans.getAll() end

---Get the number of humans.
---@return integer count How many Human objects there are.
function humans.getCount() end

---Create a new human.
---@param position Vector The position of the new Human.
---@param rotation RotMatrix The rotation of the new Human.
---@param player Player The player whose human this will be.
---@return Human? human The created human, or nil on failure.
function humans.create(position, rotation, player) end

---Library for managing ItemType objects.
---itemTypes[index: integer] -> ItemType
itemTypes = {}

---Get all item types.
---@return ItemType[] itemTypes A list of all ItemType objects.
function itemTypes.getAll() end

---Get the number of item types.
---@return integer count How many ItemType objects there are.
function itemTypes.getCount() end

---Library for managing Item objects.
---items[index: integer] -> Item
items = {}

---Get all items.
---@return Item[] items A list of all Item objects.
function items.getAll() end

---Get the number of items.
---@return integer count How many Item objects there are.
function items.getCount() end

---Create a new item.
---@param type integer The type of the item.
---@param position Vector The position of the item.
---@param rotation RotMatrix The rotation of the item.
---@return Item? item The created item, or nil on failure.
function items.create(type, position, rotation) end

---Create a new item.
---@param type integer The type of the item.
---@param position Vector The position of the item.
---@param velocity Vector The initial velocity of the item.
---@param rotation RotMatrix The rotation of the item.
---@return Item? item The created item, or nil on failure.
function items.create(type, position, velocity, rotation) end

---Create a floppy rope consisting of many items.
---@param position Vector The position of the rope. Seems to be offset.
---@param rotation Vector The rotation of the rope.
---@return Item? item The created item, or nil on failure.
---@deprecated
function items.createRope(position, rotation) end

---Library for managing Vehicle objects.
---vehicles[index: integer] -> Vehicle
vehicles = {}

---Get all vehicles.
---@return Vehicle[] vehicles A list of all Vehicle objects.
function vehicles.getAll() end

---Get the number of vehicles.
---@return integer count How many Vehicle objects there are.
function vehicles.getCount() end

---Create a new vehicle.
---@param type integer The type of the vehicle.
---@param position Vector The position of the vehicle.
---@param rotation RotMatrix The rotation of the vehicle.
---@param color integer The color of the vehicle.
---@return Vehicle? vehicle The created vehicle, or nil on failure.
function vehicles.create(type, position, rotation, color) end

---Library for managing Bullet objects.
bullets = {}

---Get all bullets.
---@return Bullet[] bullets A list of all Bullet objects.
function bullets.getAll() end

---Get the number of bullets.
---@return integer count How many Bullet objects there are.
function bullets.getCount() end

---Library for managing RigidBody objects.
---rigidBodies[index: integer] -> RigidBody
rigidBodies = {}

---Get all rigid bodies.
---@return RigidBody[] rigidBodies A list of all RigidBody objects.
function rigidBodies.getAll() end

---Get the number of rigid bodies.
---@return integer count How many RigidBody objects there are.
function rigidBodies.getCount() end

---Library for managing Bond objects.
---bonds[index: integer] -> Bond
bonds = {}

---Get all bonds.
---@return Bond[] bonds A list of all Bond objects.
function bonds.getAll() end

---Get the number of bonds.
---@return integer count How many Bond objects there are.
function bonds.getCount() end

---Library for managing Street objects.
---streets[index: integer] -> Street
streets = {}

---Get all streets.
---@return Street[] streets A list of all Street objects.
function streets.getAll() end

---Get the number of streets.
---@return integer count How many Street objects there are.
function streets.getCount() end

---Library for managing StreetIntersection objects.
---intersections[index: integer] -> StreetIntersection
intersections = {}

---Get all street intersections.
---@return StreetIntersection[] intersections A list of all StreetIntersection objects.
function intersections.getAll() end

---Get the number of street intersections.
---@return integer count How many StreetIntersection objects there are.
function intersections.getCount() end

---@class ListDirectoryEntry
---@field isDirectory boolean Whether the entry is a directory.
---@field name string The name of the file/directory. Ex. "asphalt2.png".
---@field stem string The stem of the filename if this is a file. Ex. "asphalt2".
---@field extension string The extension of the filename if this is a file. Ex. ".png".

---Get the contents of a directory.
---@param path string The path to the directory to scan.
---@return ListDirectoryEntry[] entries A list of all entries in the directory.
function os.listDirectory(path) end

---Create a directory if it does not already exist.
---@param path string The path of the directory.
---@return boolean created Whether the directory was created.
function os.createDirectory(path) end

---Get an accurate clock value counting up in real seconds.
---@return number seconds The number of seconds elapsed, with millisecond precision.
function os.realClock() end