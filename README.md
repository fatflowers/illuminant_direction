illuminant_direction
====================

Finding the iliuminant direction

  Author: 孙雷  
  实现了这篇文章中的算法，目的是为了计算图像中的光照方向  
  A. Pentland, "Finding the iliuminant direction," J. Opt. Soc.Amer., vol. 72, no. 4, 1982.  
  2014年11月18日 11:07:08  
  参数：  
      image：图像对应矩阵    
      region_size：计算光照方向时正方形区域的边长
  返回值：  
      direction：对于每一个region有一个光源方向，所以direction的大小为(int32((size(image, 1) - 2) / region_size), int32((size(image, 2) - 2) / region_size), 3)  
  异常：  
      direction = 0  

