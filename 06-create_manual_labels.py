import os

def make_label_files(audio_p, lab_p):

    if not os.path.isdir(lab_p):
        os.mkdir(lab_p)

    for fname in sorted([x for x in os.listdir(audio_p) if x.endswith('.wav')]):
        base = os.path.splitext(fname)[0]
        outname = os.path.join(lab_p, base + '.txt')
        with open(outname, 'w') as w:
            w.write(f'{base.upper()}\n')

if __name__ == '__main__':

    VAL_AUDIO = 'val/audio16_manual'
    VAL_LAB = 'val/orth_manual'

    TEST_AUDIO = 'test/audio16_manual'
    TEST_LAB = 'test/orth_manual'

    TRAIN_AUDIO = 'train/audio16_manual'
    TRAIN_LAB = 'train/orth_manual'

    make_label_files(VAL_AUDIO, VAL_LAB)
    make_label_files(TEST_AUDIO, TEST_LAB)
    make_label_files(TRAIN_AUDIO, TRAIN_LAB)
