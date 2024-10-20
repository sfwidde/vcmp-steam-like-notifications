/*
 * https://github.com/sfwidde/vcmp-steam-like-notifications
 * Steam-like notifications for Vice City: Multiplayer (VC:MP) 0.4
 * Author: sfwidde ([R3V]Kelvin)
 * 2020-09-15
 */

const NF_MAX_ITEMS      = 5;         // Max. possible notifications on screen at once
const NF_TEXT_MAX_LINES = 4;         // Max. lines of text that can fit within a notification
const NF_TEXT_FONT_NAME = "Verdana"; // Notifications' text font name
const NF_MAX_MOVE_TIMES = 11;
const NF_MOVE_ALPHA     = 24;

// -----------------------------------------------------------------------------

class Notification
{
	background = null; // GUISprite
	logo       = null; // GUISprite
	text       = null; // array(NF_TEXT_MAX_LINES, GUILabel)
	lifespan   = 0;    // Lifetime of the notification

	active      = false; // Should be processed or not?
	activeTicks = 0;     // Ticks when bacame active
	moving      = false; // Whether moving upwards or not
	movedTimes  = 0;     // Times it has moved upwards (used for a smooth moving effect)
}

function Notification::constructor()
{
	local c = ::Colour(255, 255, 255);

	// Create background
	background = ::GUISprite();
	background.SetTexture("nf_bg.png");
	background.Color = c;
	background.Size = ::GUI.RelativeVectorScreen(0.2, 0.1);

	// Create logo
	logo = ::GUISprite();
	logo.SetTexture("nf_logo.png");
	logo.Color = c;
	logo.Size = ::GUI.RelativeVectorScreen(0.045, 0.075);
	logo.Position = ::GUI.RelativeVectorScreen(0.0075, 0.0125);
	background.AddChild(logo);

	// Create text
	local s = ::GUI.RelativeVectorScreen(0.14, 0.03);
	local fs = ::GUI.RelativeFontSize(0.0055);
	text = ::array(NF_TEXT_MAX_LINES);
	for (local i = 0, lineLabel; i < NF_TEXT_MAX_LINES; ++i)
	{
		lineLabel = ::GUILabel();
		lineLabel.AddFlags(GUI_FLAG_TEXT_SHADOW | GUI_FLAG_TEXT_TAGS);
		lineLabel.Size = s;
		lineLabel.Position = ::GUI.RelativeVectorScreen(0.06, 0.0025 + (i * 0.02));
		lineLabel.FontName = NF_TEXT_FONT_NAME;
		lineLabel.FontSize = fs;
		lineLabel.TextAlignment = GUI_ALIGN_LEFT;
		background.AddChild(lineLabel);

		text[i] = lineLabel;
	}

	background.Alpha = 0; // Preloaded, should not be seen
}

function Notification::SetText(rawText, textColor)
{
	rawText = ::split(rawText, "\n");
	local lineCount = rawText.len();
	// Truncate if text exceeds maximum lines limit
	if (lineCount > NF_TEXT_MAX_LINES)
	{
		rawText.resize(NF_TEXT_MAX_LINES);
		lineCount = NF_TEXT_MAX_LINES;
	}

	local lineLabel, lineText;
	local colorTag = ::format("[#%06x]", (textColor.Hex >>> 8)); // W/o alpha
	for (local i = 0; i < NF_TEXT_MAX_LINES; ++i)
	{
		lineLabel = text[i];
		// Clear text if line is unused
		if ((i + 1) > lineCount)
		{
			lineLabel.Text = "";
			continue;
		}

		lineText = rawText[i];
		lineLabel.TextColor = textColor;
		// Entire line should be bold
		if (lineText.len() && (lineText[0] == '\b'))
		{
			lineLabel.FontFlags = GUI_FFLAG_BOLD;
			lineText = lineText.slice(1);
		}
		else
		{
			lineLabel.FontFlags = GUI_FFLAG_NONE;
		}
		// Workaround so that colors don't get mixed up
		lineLabel.Text = (colorTag + lineText + "[#d]");
	}
}

function Notification::WakeUp(text, textColor, lifespan)
{
	background.Alpha = 0;
	background.Position = ::GUI.RelativeVectorScreen(0.8, 1.0);
	SetText(text, textColor);
	this.lifespan = lifespan;

	active = true;
	activeTicks = ::Script.GetTicks();
	moving = true;
	movedTimes = 0;
}

function Notification::IsDone()
{
	return (::Script.GetTicks() - activeTicks) > lifespan;
}

// -----------------------------------------------------------------------------

nf <-
{
	items = ::array(NF_MAX_ITEMS)
};

function nf::PreloadItems()
{
	for (local i = 0; i < NF_MAX_ITEMS; ++i)
	{
		items[i] = ::Notification();
	}
}

function nf::ProcessItems()
{
	local background;
	local y;
	foreach (i, item in items)
	{
		// Do not process notification if it should not be processed (duh)
		if (!item.active) { continue; }

		background = item.background;
		y = background.Size.Y / (NF_MAX_MOVE_TIMES - 1);
		// Has notification's lifetime ended?
		if (item.IsDone())
		{
			background.Position.Y += y;
			if ((++item.movedTimes) >= NF_MAX_MOVE_TIMES)
			{
				// This notification is done
				background.Alpha = 0;
				item.active = false;
				item.activeTicks = 0;
				item.moving = false;
				item.movedTimes = 0;
			}
			else { background.Alpha -= NF_MOVE_ALPHA; }

			for (--i; i >= 0; --i)
			{
				item = items[i];
				if (item.active && !item.IsDone())
				{
					item.background.Position.Y += y;
				}
			}
		}
		// Still alive and moving (upwards)
		else if (item.moving)
		{
			background.Position.Y -= y;
			// Already moved enough times...
			if ((++item.movedTimes) >= NF_MAX_MOVE_TIMES)
			{
				// Completely visible
				background.Alpha = 255;
				// Should no longer move. Wait for lifespan to end
				item.moving = false;
				item.movedTimes = 0;
			}
			// Smooth fade-in
			else { background.Alpha += NF_MOVE_ALPHA; }

			// This notification is pushing others above it as it moves
			for (--i; i >= 0; --i)
			{
				item = items[i];
				if (item.active && !item.IsDone())
				{
					item.background.Position.Y -= y;
				}
			}
		}
	}
}

function nf::New(text, textColor, lifespan)
{
	// Transfer ownerships
	local topItem = items[0];
	for (local i = 0; i < (NF_MAX_ITEMS - 1); ++i)
	{
		items[i] = items[i + 1];
	}
	// Make bottom notification active
	(items[NF_MAX_ITEMS - 1] = topItem).WakeUp(text, textColor, lifespan);
}

function nf::HandleServerData(stream)
{
	local r = stream.ReadByte();
	local g = stream.ReadByte();
	local b = stream.ReadByte();
	local lifespan = stream.ReadInt();
	local message = stream.ReadString();
	New(message, ::Colour(r, g, b), lifespan);
}
