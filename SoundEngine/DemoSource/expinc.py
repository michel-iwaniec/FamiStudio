import sys
import argparse
import re

re_include = re.compile(r'\.include "(.*[.].*)"')
re_incbin = re.compile(r'\.incbin "(.*[.].*)"')

def file_lines(filename):
    '''
    Iterates over lines in a file.
    
    .include commands are expanded by calling this function recursively, and lines returned as if they were part of the original file.
    
    .incbin commands are expanded by turning each binary byte into a .db command
    '''
    with open(filename, 'rt') as f:
        for line in f:
            m_include = re_include.match(line)
            m_incbin = re_incbin.match(line)
            if m_include is not None:
                #sys.stdout.write(line)
                #print('Matched .include')
                #print(m_include.group(1))
                for _line in file_lines(m_include.group(1)):
                    yield _line
            elif m_incbin is not None:
                #sys.stdout.write(line)
                #print('Matched .incbin')
                #print(m.group(1))
                with open(m_incbin.group(1), 'rb') as _f:
                    # Read byte array
                    bindata = _f.read()
                    for b in bindata:
                        yield f'.db 0x{b:02X}\n'
            else:
                yield line

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=f'Expand .include and .incbin')
    parser.add_argument('--input', type=str, required=True,
                        nargs='+',
                        help='Input filename')
    args = parser.parse_args()

    filenames = args.input
    filename = filenames[0]
    for line in file_lines(filename):
        sys.stdout.write(line)
#    with open(filename, 'rt') as f:
#        for line in f:
#            m = re_include.match(line)
#            if m is not None:
#                sys.stdout.write(line)
#                print('Matched .include')
#                print(m.group(1))
#                
#            m = re_incbin.match(line)
#            if m is not None:
#                sys.stdout.write(line)
#                print('Matched .incbin')
#                print(m.group(1))
#            #sys.stdout.write(line)

