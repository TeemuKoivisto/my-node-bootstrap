import { Router } from 'express'

import { validateBody } from '../middlewares/validateBody'

import * as userCtrl from '../controllers/user/user.ctrl'

const router: Router = Router()

router.post('/login',
  validateBody(userCtrl.USER_CREDENTIALS_SCHEMA),
  userCtrl.loginUser)

router.get('/users', userCtrl.getUsers)
router.post('/user',
  validateBody(userCtrl.USER_CREATE_SCHEMA),
  userCtrl.createUser)

export default router
