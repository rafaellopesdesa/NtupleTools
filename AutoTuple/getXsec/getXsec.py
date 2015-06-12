import sys, getopt
import pprint
sys.path.append('/afs/cern.ch/cms/PPD/PdmV/tools/McM/')
from rest import *

def main(argv):
    dataset_in=''
    try:
        opts, args = getopt.getopt(argv,"hi:",["dataset="])
    except getopt.GetoptError:
        print 'test.py -i <input_dataset>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'test.py -i <input_dataset>'
            sys.exit()
        elif opt in ("-i", "--dataset"):
            dataset_in = arg

    print 'Input dataset is ', dataset_in
    mcm = restful( dev=False )
    rs = mcm.getA('requests', query='produce='+dataset_in)
    for r in rs:
        parent = r['input_dataset']
        print parent
        while 'GEN' not in parent:
            print parent
            rt = mcm.getA('requests', query='produce='+parent)
            for s in rt:
                parent = s['input_dataset']

        rt = mcm.getA('requests', query='produce='+parent)
        for s in rt:
            t = s['generator_parameters']
            u = t[-1]
            print 'cross section: %.5f' % u['cross_section']
            print 'filter efficiency: %.5f' % u['filter_efficiency']

if __name__ == "__main__":
    main(sys.argv[1:])
    


