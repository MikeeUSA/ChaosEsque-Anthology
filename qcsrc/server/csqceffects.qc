void te_csqc_lightningarc(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_LIGHTNINGARC);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}

void te_csqc_firearc(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_FIREARC);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}

void te_csqc_lightningarcb(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_LIGHTNINGARCB);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}

void te_csqc_lightningarcc(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_LIGHTNINGARCC);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}

void te_csqc_lightningarcd(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_LIGHTNINGARCD);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}

void te_csqc_lightningarcp(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_LIGHTNINGARCP);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}
