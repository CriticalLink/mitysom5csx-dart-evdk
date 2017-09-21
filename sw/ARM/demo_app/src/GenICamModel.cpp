#include "GenICamModel.h"

using namespace GenApi;
using namespace std;

tcGenICamModel::tcGenICamModel(GenApi::INodeMap& arNodeMap)
: mrNodeMap (arNodeMap)
{
}

tcGenICamModel::~tcGenICamModel()
{
}

int tcGenICamModel::SetParam(std::string Name, std::string Value)
{
	int retval = 0;
	try
	{
		GenApi::CNodePtr pItem = mrNodeMap.GetNode(Name.c_str());
		if (!pItem)
		{
			cerr << "Could not get node for " <<  Name << endl;
			return -1;
		}
		GenApi::EAccessMode am = pItem->GetAccessMode();
		if (GenApi::WO != am && GenApi::RW != am)
		{
			cerr << "Node " << Name << " is not writeable" << endl;
			return -1;
		}
		switch(pItem->GetPrincipalInterfaceType())
		{

		case GenApi::intfIInteger:
		{
			GenApi::CIntegerPtr pReg = (GenApi::CIntegerPtr)pItem;
			int var = atoi(Value.c_str());
			pReg->SetValue(var);
		}
		break;
		case GenApi::intfIBoolean:
		break;
		case GenApi::intfIFloat:
		{
			GenApi::CFloatPtr pReg = (GenApi::CFloatPtr)pItem;
			float var = atof(Value.c_str());
			pReg->SetValue(var);
		}
		case GenApi::intfIString:
		case GenApi::intfIValue:
		break;
		case GenApi::intfIEnumeration:
		{
			GenApi::CEnumerationPtr pReg = (GenApi::CEnumerationPtr)pItem;
			pReg->FromString(Value.c_str());
		}
		case GenApi::intfICommand:
		case GenApi::intfIRegister:
		case GenApi::intfICategory:
		case GenApi::intfIEnumEntry:
		case GenApi::intfIPort:
		case GenApi::intfIBase:
		default:
			break;
		}
	}
	catch(...)
	{
		cerr << "tcGenICamModel::SetParam Caught Exception" << endl;
		retval = -1;
	}

	return retval;
}

void tcGenICamModel::Dump(void)
{
	GenApi::CNodePtr pRoot = mrNodeMap.GetNode("Root");
	GenApi::CCategoryPtr pCatRoot = (GenApi::CCategoryPtr)pRoot;
	if (pCatRoot.IsValid())
	{
		GenApi::FeatureList_t Categories;
		pCatRoot->GetFeatures(Categories);
		for (GenApi::FeatureList_t::iterator itCategory = Categories.begin();
			itCategory != Categories.end(); itCategory++)
		{
			GenApi::CCategoryPtr pCat = (*itCategory)->GetNode();
			if (pCat.IsValid())
			{
				GenApi::FeatureList_t Features;
				pCat->GetFeatures(Features);
				for (GenApi::FeatureList_t::iterator itFeature = Features.begin();
					itFeature != Features.end(); itFeature++)
				{
					GenApi::EAccessMode am = (*itFeature)->GetNode()->GetAccessMode();
					if (GenApi::RO != am && GenApi::RW != am)
					{
						continue;
					}
					switch((*itFeature)->GetNode()->GetPrincipalInterfaceType())
					{
					case GenApi::intfIInteger:
					{
						cout << (*itFeature)->GetNode()->GetName().c_str();
						GenApi::CIntegerPtr pReg = (*itFeature)->GetNode();
						cout << ":\t" << pReg->GetValue() << endl;
					}
					break;
					case GenApi::intfIBoolean:
					{
						cout << (*itFeature)->GetNode()->GetName().c_str();
						GenApi::CBooleanPtr pReg = (*itFeature)->GetNode();
						cout << ":\t" << pReg->GetValue() << endl;
					}
					break;
					case GenApi::intfIFloat:
					{
						cout << (*itFeature)->GetNode()->GetName().c_str();
						GenApi::CFloatPtr pReg = (*itFeature)->GetNode();
						cout << ":\t" << pReg->GetValue() << endl;
					}
					break;
					case GenApi::intfIString:
					{
						cout << (*itFeature)->GetNode()->GetName().c_str();
						GenApi::CStringPtr pReg = (*itFeature)->GetNode();
						cout << ":\t" << pReg->GetValue() << endl;
					}
					break;
					case GenApi::intfIValue:
					{
						cout << (*itFeature)->GetNode()->GetName().c_str();
						GenApi::CValuePtr pReg = (*itFeature)->GetNode();
						cout << ":\t" << pReg->ToString() << endl;
					}
					break;
					case GenApi::intfIEnumeration:
					{
						cout << (*itFeature)->GetNode()->GetName().c_str();
						GenApi::CEnumerationPtr pReg = (*itFeature)->GetNode();
						cout << ":\t" << pReg->ToString() << endl;
					}
					break;
					case GenApi::intfICommand:
					case GenApi::intfIRegister:
					case GenApi::intfICategory:
					case GenApi::intfIEnumEntry:
					case GenApi::intfIPort:
					case GenApi::intfIBase:
					default:
						break;
					}
				}
			}
		}
	}
}

