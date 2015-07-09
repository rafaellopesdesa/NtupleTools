#include "TH1.h"
#include "TFile.h"
#include "TTree.h"
#include "TList.h"
#include "/home/users/cgeorge/software/dataMCplotMaker/dataMCplotMaker.h"

vector<std::string> getAliasNames(TTree *t){

  //Vector to return results
  vector<std::string> v_aliasnames;
  
  //Skip if no entries
  if (t->GetEntriesFast() == 0) return v_aliasnames;

  //Get list of aliases
  TList *t_list =  t->GetListOfAliases();

  //Loop over list, skip entries that are vectors of vectors, or strings
  for(int i = 0; i < t_list->GetSize(); i++) {
    std::string aliasname(t_list->At(i)->GetName());
    TBranch *branch = t->GetBranch(t->GetAlias(aliasname.c_str()));
    std::string branchname(branch->GetName());
    std::string branchtitle(branch->GetTitle());

    if(branchname.find("intss") == 0 || branchname.find("floatss") == 0 || branchname.find("doubless") == 0 || branchname.find("LorentzVectorss") < branchname.length() || branchname.find("timestamp") < branchname.length()){
      cout << "Sorry, I dont know about vector of vectors of objects. Will be skipping " << aliasname << endl;
      continue;
    }

    if(branchname.find("std::string") < branchname.length()){
      cout << "Sorry, I don't know how to graphically represent std::strings in only 3 dimensions." << " Put in a feature request. Will be skipping " << aliasname << endl;
      continue;
    }

    v_aliasnames.push_back(aliasname);
  }

  //Sort alias names alphabetically
  sort(v_aliasnames.begin(), v_aliasnames.end());
  
  //Return aliases names
  return v_aliasnames;
}

vector<std::string> getUncommonBranches(vector<std::string> aliasnames, vector<std::string> v_commonBranches){
  
  vector<std::string> v_notCommonBranches;
  for(vector<std::string>::iterator it = aliasnames.begin(); it != aliasnames.end(); it++){
    if(find(v_commonBranches.begin(), v_commonBranches.end(), *it) != v_commonBranches.end()) continue;
    v_notCommonBranches.push_back(*it);
  }

  sort(v_notCommonBranches.begin(), v_notCommonBranches.end());

  return v_notCommonBranches;

}

void test(){

  TFile *file_old = new TFile("/home/users/sicheng/play/comparison/merged_ntuple_143.root");
  TFile *file_new = new TFile("/home/users/sicheng/play/comparison/merged_ntuple_9.root");

  TTree *tree_old = (TTree*)file_old->Get("Events");
  TTree *tree_new = (TTree*)file_new->Get("Events");
 
  //Get aliases in both trees
  vector<std::string> oldAliasNames = getAliasNames(tree_old);
  vector<std::string> newAliasNames = getAliasNames(tree_new);

  //Figure out common and notCommonBranches
  vector<std::string> commonBranches;
  vector<std::string> oldOnlyBranches;
  vector<std::string> newOnlyBranches;
  
  for(vector<std::string>::iterator it = oldAliasNames.begin(); it != oldAliasNames.end(); it++) {
    if(find(newAliasNames.begin(), newAliasNames.end(), *it) != newAliasNames.end()) commonBranches.push_back(*it);
  }

  //Figure out which branches are not common 
  oldOnlyBranches = getUncommonBranches(oldAliasNames, commonBranches);
  newOnlyBranches = getUncommonBranches(newAliasNames, commonBranches);

  //Loop over common branches, test for sameness
  for (unsigned int i = 0; i < commonBranches.size(); i++){

    cout << "Working on " << commonBranches[i] << endl;
    int suppress = false;

    //Make plot
    tree_old->Draw(Form("%s%s>>hist_old", commonBranches[i].c_str(), commonBranches[i].find("p4") < commonBranches[i].length() ? ".Pt()" : "")); 
    tree_new->Draw(Form("%s%s>>hist_new", commonBranches[i].c_str(), commonBranches[i].find("p4") < commonBranches[i].length() ? ".Pt()" : "")); 

    TH1F *hist_old = (TH1F*)gDirectory->Get("hist_old");
    TH1F *hist_new = (TH1F*)gDirectory->Get("hist_new");

    //Give both histos the same binning, if not already done
    int old_min = hist_old->GetXaxis()->GetBinLowEdge(1);
    int old_max = hist_old->GetXaxis()->GetBinLowEdge( hist_old->GetNbinsX() ) + hist_old->GetXaxis()->GetBinWidth( hist_old->GetNbinsX() );
    int old_nbins = hist_old->GetNbinsX();
    int new_min = hist_new->GetXaxis()->GetBinLowEdge(1);
    int new_max = hist_new->GetXaxis()->GetBinLowEdge( hist_new->GetNbinsX() ) + hist_new->GetXaxis()->GetBinWidth( hist_new->GetNbinsX() );
    int new_nbins = hist_new->GetNbinsX();
    int nbins = std::max(old_nbins, new_nbins); 
    float min = std::min(old_min, new_min); 
    float max = std::max(old_max, new_max); 
    if (old_min != new_min || old_max != new_max || old_nbins != new_nbins){
      delete hist_old;
      delete hist_new;
      hist_old = new TH1F("hist_old", "hist_old", nbins, min, max); 
      hist_new = new TH1F("hist_new", "hist_new", nbins, min, max); 
      tree_old->Draw(Form("%s%s>>hist_old", commonBranches[i].c_str(), commonBranches[i].find("p4") < commonBranches[i].length() ? ".Pt()" : "")); 
      tree_new->Draw(Form("%s%s>>hist_new", commonBranches[i].c_str(), commonBranches[i].find("p4") < commonBranches[i].length() ? ".Pt()" : "")); 
    }

    //Determine number of histos that are empty in both
    int nempty = 0; 
    int whichNotEmpty = 0;
    for (int j = 1; j <= nbins; j++){
      if (hist_old->GetBinContent(j) == 0 && hist_new->GetBinContent(j) == 0) nempty++;
      else whichNotEmpty = j;
    }

    //If it's being fucking stupid and putting everything in 1 bin, redraw yet again
    int niter = 0;
    bool keepGoing = ((std::min(hist_old->GetBinContent(1), hist_new->GetBinContent(1)) == 0) || (std::min(hist_old->GetBinContent(nbins), hist_new->GetBinContent(nbins)) == 0));
    while (keepGoing == true && niter < 15){
      for (int j = 1; j < nbins; j++){
        if (hist_old->GetBinContent(j) != 0){ min = hist_old->GetXaxis()->GetBinLowEdge(j); break; } 
        if (hist_new->GetBinContent(j) != 0){ min = hist_new->GetXaxis()->GetBinLowEdge(j); break; } 
      }
      for (int j = nbins; j > 0; j--){
        if (hist_old->GetBinContent(j) != 0){ max = hist_old->GetXaxis()->GetBinLowEdge(j) + 2*hist_old->GetXaxis()->GetBinWidth(j); break; } 
        if (hist_new->GetBinContent(j) != 0){ max = hist_new->GetXaxis()->GetBinLowEdge(j) + 2*hist_new->GetXaxis()->GetBinWidth(j); break; } 
      }
      delete hist_old;
      delete hist_new;
      hist_old = new TH1F("hist_old", "hist_old", nbins, min, max); 
      hist_new = new TH1F("hist_new", "hist_new", nbins, min, max); 
      tree_old->Draw(Form("%s%s>>hist_old", commonBranches[i].c_str(), commonBranches[i].find("p4") < commonBranches[i].length() ? ".Pt()" : "")); 
      tree_new->Draw(Form("%s%s>>hist_new", commonBranches[i].c_str(), commonBranches[i].find("p4") < commonBranches[i].length() ? ".Pt()" : "")); 
      nempty = 0; 
      for (int j = 1; j <= nbins; j++){
        if (hist_old->GetBinContent(j) == 0 && hist_new->GetBinContent(j) == 0) nempty++;
        else whichNotEmpty = i;
      }
      niter++;
      keepGoing = ((std::max(hist_old->GetBinContent(1), hist_new->GetBinContent(1)) == 0) || (std::max(hist_old->GetBinContent(nbins), hist_new->GetBinContent(nbins)) == 0));
     if (keepGoing && (std::max(hist_old->GetBinContent(1), hist_new->GetBinContent(1)) != 0) && (std::max(hist_old->GetBinContent(nbins-1), hist_new->GetBinContent(nbins-1)) != 0)) keepGoing = false;
     if ( (max-min)/max < .001){ keepGoing = false; suppress = true;} 
    }

    //Normalize both histos
    hist_old->Scale(1./hist_old->GetEntries());
    hist_new->Scale(1./hist_new->GetEntries());

    //Print results
    float chi2test = hist_new->Chi2Test(hist_old, "CHI2/NDFWWOFUF");
    if (chi2test*100 < 0.1) suppress = true;

    //Print histogram if not suppressed
    if (suppress) cout << " --> Suppressed!" << endl;
    if (!suppress){ 
      vector<TH1F*> old_vector;
      old_vector.push_back(hist_old);
      vector<string> titles;
      titles.push_back("Old");
      dataMCplotMaker(hist_new, old_vector, titles, Form("%.2f", chi2test*100), commonBranches[i].c_str(), Form("--noErrBars --isLinear --dataName New --topYaxisTitle New/Old --xAxisOverride --noDivisionLabel --outputName hists/diff%i", i));
    }

    delete hist_old;
    delete hist_new;

  }

}
