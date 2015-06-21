#include "TFile.h"

int getNevents(std::string filename){
  TFile *file = new TFile(filename.c_str()); 
  TTree *tree = (TTree*)file->Get("Events"); 
  int nEvents = tree->GetEntries(); 
  cout << nEvents << endl;
  return nEvents; 
}
