#
g++ -c -fPIC -c *.c  -ggdb -I/usr/include/python2.7 -L/usr/lib/python2.7 -I/usr/local/include/boost -L/usr/local/lib/boost -I/usr/local/include/boost/python -L/usr/local/lib/boost/python 

g++ -fPIC -shared -Wl,-soname,GPSwavesC.so -ggdb -o GPSwavesC.so  -Wno-undef -I/home/kay/Desktop/ETEINEUROPE/raspberrypi/GPSwaves *.o -I/usr/include/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu -lm -g -I/usr/local/include/boost  -L/usr/local/lib/boost  -I/usr/include/python2.7 -I/usr/local/include/boost/python -L/usr/local/lib/boost/python -lboost_python27 -lboost_numpy27




