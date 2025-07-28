import { useUserStore } from '@/stores/user'
import router from './index'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import storage from 'store'

const whiteList = ['/user/login', '/user/register'] // 不重定向白名单

router.beforeEach(async (to, from, next) => {
  NProgress.start()

  const token = localStorage.getItem('token') || storage.get('ACCESS_TOKEN')
  const userStore = useUserStore()

  if (token) {
    // 如果有token但userStore中没有用户信息，从storage恢复
    if (!userStore.userInfo) {
      const storedUserInfo = storage.get('USER_INFO')
      if (storedUserInfo) {
        userStore.setUserInfo(storedUserInfo)
        console.log('从storage恢复用户信息:', storedUserInfo)
      }
    }

    if (whiteList.includes(to.path)) {
      // 已登录状态下访问登录/注册页面，重定向到首页
      next({ path: '/' })
    } else {
      // 已登录，直接通过
      next()
    }
  } else {
    if (whiteList.includes(to.path)) {
      // 未登录可以访问白名单页面
      next()
    } else {
      // 未登录且访问的不是白名单页面，重定向到登录页
      next(`/user/login?redirect=${to.path}`)
    }
  }
  NProgress.done()
})

router.afterEach(() => {
  NProgress.done()
})
