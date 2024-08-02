pid=$(ps -a | grep 'b1-w.propert' | grep 'b1-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b2-w.propert' | grep 'b2-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b3-w.propert' | grep 'b3-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'run-produce' | grep 'run-producer\.sh' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'run-consume' | grep 'run-consumer\.sh' | awk '{print $1}')
sudo kill -9 $pid
