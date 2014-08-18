#include <TString.h>
#include <TChain.h>

void counts(TString folder)
{
    TChain * ch = new TChain("Events");
    ch->Add(folder+"/*.root");
    std::cout << "nevents=" << ch->GetEntries() << std::endl;
}
