import numpy as np

class FindS(object):
    def __init__(self, raw_dataset):
        self.concepts = np.array(raw_dataset)[:,:-1]
        self.target = np.array(raw_dataset)[:,-1]

    def train(self):
        for i, val in enumerate(self.target):
            if val == 1:
                max_hypothesis = self.concepts[i].copy()
                break

        for i, val in enumerate(self.concepts):
            if self.target[i] == 1:
                for j in range(len(max_hypothesis)):
                    if val[j] != max_hypothesis[j]:
                        max_hypothesis[j] = '?'
                    else: pass

        self.dataset = max_hypothesis
        return self.dataset

    def process(self, datatest, result):
        pval = int(0)
        nval = int(0)
        for j, val in enumerate(datatest):
            for i in range( (len(val)-1) ):
                if bool(datatest[i] == self.dataset[i]): pval += 1
                elif bool(self.dataset[i] == "?"): pval += 1
                else: nval += 1

            if pval == nval : result[j] = 0
            elif pval == (len(val) - 1) : result[j] = 1
            else: result[j] = -1