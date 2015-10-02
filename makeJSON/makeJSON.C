#include "TFile.h"
#include "TTree.h"

#include "CORE/CMS3.h"

int makeJSON(const char* name){

  TFile *file = new TFile(name); 
  TTree *tree = (TTree*)file->Get("Events"); 
  cms3.Init(tree); 

  for (unsigned int i = 0; i < tree->GetEntries(); i++){
    cms3.GetEntry(i); 
    cout << tas::evt_run() << " " << tas::evt_lumiBlock() << endl;
  }

  return 0; 

}
