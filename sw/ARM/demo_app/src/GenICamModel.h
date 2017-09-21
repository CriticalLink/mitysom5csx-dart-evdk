#ifndef GENICAMMODEL_H
#define GENICAMMODEL_H

#include <GenApi/GenApi.h>

class tcGenICamModel
{
public:
	tcGenICamModel(GenApi::INodeMap& apNodeMap);
	virtual ~tcGenICamModel();

	void Dump(void);

	int SetParam(std::string Name, std::string Value);

protected:
	GenApi::INodeMap& mrNodeMap;
};
#endif
