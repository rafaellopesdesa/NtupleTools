#include <iostream>
#include <fstream>
#include "TChain.h"
#include "TFile.h"
#include "TTree.h"
#include <string>

using namespace std;

int checkNumMergedEvents(const string& fileList, const string& outFile ){

  if (fileList == ""){
    cout<<"File list not supplied. Please supply a list of files to be merged. Exiting.."<<endl;
    return 1;
  }

  if (outFile == ""){
    cout<<"outFile name not supplied. Please supply a name for merged file. Exiting.."<<endl;
    return 2;
  }

  TChain ch1("Events");
  cout<<"Parsing File: "<<fileList.c_str()<<endl;
  ifstream file(fileList.c_str());
  if (!file.good()){
    cout<<Form("%s is not a good file. exiting..",fileList.c_str())<<endl;
    return 3;
  }

  string ntupleLocation;

  ///////////////////////////////////////
  //parses list of root files to merge.//
  ///////////////////////////////////////
  while (file){
    ntupleLocation = "";
    file>>ntupleLocation;
    if (ntupleLocation.empty()) continue;
    else{
      ch1.Add( ("root://cmsxrootd.fnal.gov///" + ntupleLocation.substr(11)).c_str() );
    }
  }

  unsigned int nEntries = ch1.GetEntries();

  cout << Form("Merging Sample with %u entries... ",nEntries) << endl;

  ///////////////////////////////////////
  //checks for correct number of events//
  ///////////////////////////////////////
  TFile* mergedFile = new TFile(outFile.c_str());
  TTree *mergedTree = (TTree*)mergedFile->Get("Events");
  const int mergedCount = mergedTree->GetEntries();
  const int unmergedCount = ch1.GetEntries();
  std::cout << "mergedCount = " << mergedCount << std::endl;
  std::cout << "unmergedCount = " << unmergedCount << std::endl;
  if (mergedCount != unmergedCount){
    cout << "Merged count not equal to unmerged count. Exiting..." << endl;
    return 4;
  }

  return 0;

}
