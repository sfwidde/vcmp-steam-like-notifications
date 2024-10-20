// You can change this to whatever you may seem fit, although value must be same as client-side
const STREAMID_NF_SEND = 1;

function SendPlayerNotification(
	player,        // CPlayer/null
	message,       // string
	color,         // RGB
	lifespan,      // int
	soundId = null // int/null
)
{
	// Typecheck parameters
	if (!(player instanceof CPlayer) && (typeof(player) != "null"))    { throw "player must be a CPlayer class instance, or null";   }
	if (typeof(message) != "string")                                   { throw "message must be a string";                           }
	if (!(color instanceof RGB))                                       { throw "color must be an RGB class instance";                }
	if ((typeof(lifespan) != "integer") || (lifespan < 1))             { throw "lifespan must be of type integer and higher than 0"; }
	if ((typeof(soundId) != "integer") && (typeof(soundId) != "null")) { throw "sound ID must be an integer, or null";               }

	Stream.StartWrite();
	Stream.WriteInt(STREAMID_NF_SEND); // Change this if needed (read client-side's Server::ServerData() for more details)
	Stream.WriteByte(color.r);
	Stream.WriteByte(color.g);
	Stream.WriteByte(color.b);
	Stream.WriteInt(lifespan);
	Stream.WriteString(message);
	Stream.SendStream(player);

	// If soundId == null no sound shall be played
	if (!soundId) { return; }

	// Specific player to play sound for
	if (player)
	{
		player.PlaySound(soundId);
		return;
	}

	// Sound should be played for everyone on the server
	local i = 0;
	local maxPlayers = GetMaxPlayers();
	while (i < maxPlayers)
	{
		player = FindPlayer(i++);
		if (player)
		{
			player.PlaySound(soundId);
		}
	}
}
