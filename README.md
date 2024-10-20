# Steam-like notifications for Vice City: Multiplayer (VC:MP) 0.4 servers
Click on the video below to find out what it looks like:
[![VCMP | Steam-like Notifications](https://img.youtube.com/vi/rggN5oY_sO8/0.jpg)](https://www.youtube.com/watch?v=rggN5oY_sO8)

## Installation steps
1. Download this repository by clicking on
[**Code > Download ZIP**](https://github.com/sfwidde/vcmp-steam-like-notifications/archive/refs/heads/main.zip).
2. Open up the **.zip** archive you just downloaded, then:
	1. Locate the `store` folder and extract its contents (except
	**store/script/main.nut** file!) to your server's directory.
	2. Open up the aforementioned **store/script/main.nut** file from the .zip
	archive and adapt its contents to your server's client-side main script
	(**store/script/main.nut**).
	3. Locate outer **main.nut** file from the .zip archive and paste its
	contents to any of your server-side's script files. Do not forget to read
	code comments as you adapt stuff to your script.

## Documentation
Sending a notification to a client is as easy as calling this function from your
server-side script:
- `SendPlayerNotification(CPlayer player/null,
	string message,
	RGB color,
	int lifespan,
	int soundId/null = null)`
	- `player`: Player to send notification to, or `null` for everyone on the
	server.
	- `message`: Notification content (text). Newlines (`\n`) are supported (up
	to 4 lines); a line can begin with a backspace character (`\b`), which will
	make that line entirely bold. Text tags are also supported (opening tag:
	`[#hhhhhh]`, closing tag: `[#d]`; lowercase only).
	- `color`: RGB class instance representing color of the entire text.
	- `lifespan`: How long should this notification live for (in milliseconds).
	- `soundId`: Sound to play for player when the notification is sent, `null`
	if no sound shall be played at all. Defaults to `null` if omitted.

## Examples
```
/*
 * This is the code that was used to record demonstration video:
 * https://www.youtube.com/watch?v=rggN5oY_sO8
 */

const SOUNDID_STEAM_MESSAGE = 50000;
const SOUNDID_STEAM_CAMERA1 = 50001;

function onPlayerSpawn(player)
{
	local playerPos = player.Pos;
	SendPlayerNotification(
		player,
		"You have spawned as\n" +
		"\b[#00ff00]" + GetSkinName(player.Skin) + "[#d]\n" +
		"at\n" +
		"\b[#b0b0b0]" + GetDistrictName(playerPos.x, playerPos.y) + "[#d]",
		RGB(255, 255, 255),
		10000,
		SOUNDID_STEAM_CAMERA1
	);
}

function onPlayerPM(player, playerTo, message)
{
	local playerCol = player.Color;
	SendPlayerNotification(
		playerTo,
		"You have received a private\n" +
		"message from\n" +
		"\b[#" + format("%02x%02x%02x", playerCol.r, playerCol.g, playerCol.b) + "]" + player.Name + "[#d]",
		RGB(255, 255, 255),
		3000,
		SOUNDID_STEAM_MESSAGE
	);
	return 1;
}

function onPlayerEnterVehicle(player, vehicle, door)
{
	SendPlayerNotification(
		player,
		"\nEntered vehicle ID [#b0b0b0]" + vehicle.ID + "[#d]\n" +
		"\b[#ff8c13]" + GetVehicleNameFromModel(vehicle.Model) + "[#d]",
		RGB(255, 255, 255),
		5000,
		SOUNDID_STEAM_CAMERA1
	);
}
```

## Credits
- Files [**s50000_message.wav**](store/sounds/s50000_message.wav),
[**s50001_camera1.wav**](store/sounds/s50001_camera1.wav), and
[**nf_bg.png**](store/sprites/nf_bg.png) are property of Valve Corporation.
THESE ARE MERELY USED FOR ILLUSTRATION PURPOSES AND I DO NOT INTEND TO TAKE
ANY CREDITS BASED OFF THEIR WORK BY ANY MEANS.
- [**nf_logo.png**](store/sprites/nf_logo.png) by **Pumak47**.