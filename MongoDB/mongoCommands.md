MongoDB 命令：

- mongod --dbpath D:\githubrepo\GitHub-and-World\MongoDB\db --port=27100 -f D:\githubrepo\GitHub-and-World\MongoDB\mongodb.conf

  在目录下创建MongoDB。如果需要程序访问 必须设置端口号。默认端口号为2700

- mongo --port=...

  链接数据库。 可以看到连接到了哪里

- show databases

- mongod -f [conf文件 path] 输出日志(启动服务)

- use admin：切换到admin数据库

  use [数据库名] 就直接切换到对应数据库 但是不会创建这个数据库，直到往里面创建集合才开始保存

- db.createCollection("")
  创建一个集合，约等于创建一张表格

- db.集合名称.find({若干条件}) 寻找

- db.集合名称.insert({JSON}) 写入一条json格式的信息

show collection 看有什么集合（表）

- db.shutdownServer() 关闭数据库（需要切换到admin时才可以使用）

- db.集合名称.remove({JSON的结构}) 删除数据

- db..update({旧数据，一般是ObjectID}, {新数据})更新数据

- db.集合名称.drop() 删除集合

- db.dropDatabase() 删除当前所在的数据库， 切换到某个数据库之后才可以删除
