#include <iostream>
#include <fstream>

#include "TFile.h"
#include "TTree.h"
#include "TH1.h"
#include "TSystem.h"

using namespace std;


void printColor(const char* message, const int color, bool human) {
  if( human ) printf("\033[%dm%s\033[0m\n", color, message);
  else cout << message << endl;
}


int missingDatasets(TString input="test.txt", TString output = "outfile.txt", bool humanUser = true) {
  
  //open text file with dataset list
  std::ifstream infile;
  infile.open(input);

  if(!infile.is_open()){
    printColor("ERROR: Can't open input file", 91, humanUser);
    return 0;
  }

  //loop over datasets to see if they already exist
  std::vector<TString> missing;
  std::string line;
  while (std::getline(infile, line)){

    TString dataset = line;
    bool das_failed = true;
    int loop_count = 0;

    cout << "Dataset: " << dataset << endl;
    cout << "Querying DAS..." << endl;
    
    //try up to 3 DAS queries
    while( loop_count<3 && das_failed ) {
      TString status = "";
      TString site = "";
 
      status = gSystem->GetFromPipe( "timeout 10s python das_client.py --query=\"dataset= "+dataset+" | grep dataset.status\" | tail -1" );
      site = gSystem->GetFromPipe( "timeout 10s python das_client.py --query=\"site dataset= "+dataset+" | grep site.name\" " );

      bool atUCSD = site.Contains("T2_US_UCSD");
      
      //if sample is valid, add to vector of missing samples
      if( status == "VALID" && !atUCSD) {
      	das_failed = false;
      	cout << line << " missing , will add." << status << endl;
	missing.push_back(line);
      }

      else if( status == "VALID" && atUCSD) {
      	das_failed = false;
	printColor(dataset + " already at UCSD.", 92, humanUser);
      }
      
      //if sample in production, skip and tell user
      else if( status == "PRODUCTION") {
      	das_failed = false;
	printColor(dataset + " in Production", 92, humanUser);
      }

      else if (loop_count == 2) printColor(dataset + " DAS QUERY FAILED 3 TIMES. Giving up.", 91, humanUser);
      
      else printColor("DAS QUERY FAILED, trying again.", 93, humanUser);
         
      loop_count++;
    }//das queries

    
  }//while line
  
  infile.close();

  cout << missing.size() << " missing Datasets" << endl;
  
  //if they are valid, make output file with list of missing datasets
  std::ofstream outfile;
  outfile.open(output);
  
  if(!outfile.is_open()){
    printColor("ERROR: Can't open output file", 91, humanUser);
    return 0;
  }
  
  for (unsigned int i = 0; i < missing.size(); i++){
    outfile << missing.at(i)<< "\n";
  }
  outfile.close();
  
  return 0;
}


#ifndef __CINT__
int main()
{
  missingDatasets();
  return 0;
}
#endif
