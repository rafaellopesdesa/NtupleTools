#include "TFile.h"
#include "TTree.h"

#include <iostream>


void isValidFile(std::string filename){

  std::string bad_message = "FileIsNotValid";
  std::string good_message = "FileIsValid";

  TFile* file  = new TFile(Form("%s", filename.c_str()), "READ");

  if(!file || file->IsZombie()){
    std::cout << bad_message << std::endl;
    return;
  }

  TTree *tree = (TTree*)file->Get("Events");  

  int nEventsTree = tree->GetEntriesFast();

  if(nEventsTree < 1){
    std::cout << bad_message << std::endl;
    return;
  }

  TH1F* h_pfmet = new TH1F("h_pfmet", "h_pfmet", 1000, 0, 1000);
  tree->Draw("evt_pfmet >> h_pfmet");

  float avg_pfmet = h_pfmet->GetMean(1);

  if(avg_pfmet < 0.1){
    std::cout << bad_message << std::endl;
    return;
  }

  std::cout << good_message << std::endl;
}
