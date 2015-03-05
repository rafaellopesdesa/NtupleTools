#include <string>

using namespace std;

int getSparm(string name = "T1ttbb_2J_mGo1500_mChi100_3bodydec_asymmDecOnly"){
  int which = 0;
  int pos = 0;
  string sparm;

  //See if it is gluino-based
  pos = name.find("mGo");
  if (pos > 1) which = 1;
  sparm = name.substr(pos+3, name.find("_", pos+3)-pos-3);

  //If it's not, try for stop
  if (which == 0){
    pos = name.find("mStop");
    if (pos > 1) which = 2;
    sparm = name.substr(pos+5, name.find("_", pos+5)-pos-5);
  }

  //If it's not, try for sbottom
  if (which == 0){
    pos = name.find("mSbottom");
    if (pos > 1) which = 2;
    sparm = name.substr(pos+8, name.find("_", pos+8)-pos-8);
  }

  //If not that either, return
  if (which == 0) return 0;

  //Otherwise, return what you got
  return which*100000+atoi(sparm.c_str());
}
