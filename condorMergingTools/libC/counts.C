#include <TString.h>
#include <TChain.h>

void counts(TString folder, bool do_effective = false)
{
    TChain * ch = new TChain("Events");
    ch->Add(folder+"/*.root");
    if(do_effective){
      int pos_weight = ch->GetEntries("genps_weight > 0");
      int neg_weight = ch->GetEntries("genps_weight < 0");
      int nevents_effective = pos_weight - neg_weight;
      std::cout << "nevents_effective=" << nevents_effective << std::endl;
    }
    else std::cout << "nevents=" << ch->GetEntries() << std::endl;
}
