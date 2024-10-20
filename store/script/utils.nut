function GUI::RelativeWidth(x)
{
	return (GetScreenSize().X * x).tointeger();
}

function GUI::RelativeHeight(x)
{
	return (GetScreenSize().Y * x).tointeger();
}

function GUI::RelativeVectorScreen(x, y)
{
	return ::VectorScreen(RelativeWidth(x), RelativeHeight(y));
}

function GUI::RelativeFontSize(x)
{
	local screenSize = GetScreenSize();
	return ((screenSize.X + screenSize.Y) * x).tointeger();
	// or: ((screenSize.X * x) + (screenSize.Y * x)).tointeger()
}
