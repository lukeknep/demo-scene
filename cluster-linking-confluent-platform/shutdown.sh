pid=$(ps -a | grep 'b1-w.propert' | grep 'b1-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b2-w.propert' | grep 'b2-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b3-w.propert' | grep 'b3-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'z-w.propert' | grep 'z-w\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'run-produce' | grep 'run-producer\.sh' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'run-consume' | grep 'run-consumer\.sh' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b1-w-dr.propert' | grep 'b1-w-dr\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b2-w-dr.propert' | grep 'b2-w-dr\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'b3-w-dr.propert' | grep 'b3-w-dr\.properties' | awk '{print $1}')
sudo kill -9 $pid
pid=$(ps -a | grep 'z-w-dr.propert' | grep 'z-w-dr\.properties' | awk '{print $1}')
sudo kill -9 $pid
