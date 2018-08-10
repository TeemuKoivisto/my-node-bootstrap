import { Router } from 'express'

import * as userCtrl from '../controllers/user/user.ctrl'

const router: Router = Router()

router.post('/login', userCtrl.loginUser)

router.get('/users', userCtrl.getUsers)

export default router
