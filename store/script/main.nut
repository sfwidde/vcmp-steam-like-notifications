// You can change this to whatever you may seem fit, although value must be same as server-side
const STREAMID_NF_SEND = 1;

dofile("utils.nut");
dofile("nf.nut");

function Script::ScriptLoad()
{
	::nf.PreloadItems();
}

function Script::ScriptProcess()
{
	::nf.ProcessItems();
}

function Server::ServerData(stream)
{
	// Careful! This variable is used to identify streams -- some people tend to use a byte
	// for this; if this is your case just change .ReadInt() to .ReadByte() here and
	// .WriteInt() to .WriteByte() on SendPlayerNotification() server-side function so that
	// you don't end up getting incorrect/garbage values
	local streamId = stream.ReadInt();
	switch (streamId)
	{
	case STREAMID_NF_SEND:
		::nf.HandleServerData(stream);
		return;
	}
}
