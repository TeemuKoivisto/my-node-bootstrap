import { Request, Response, NextFunction } from 'express'
import * as Joi from 'joi'
import { userService } from './user.service'

import { CustomError } from '../../common'

import { ILoginCredentials } from '../../interfaces/user'

export const USER_CREDENTIALS_SCHEMA = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).max(255).required(),
})

// export const USER_SCHEMA = Joi.object({
//   id: Joi.number().integer(),
//   name: Joi.string().min(1).max(255).required(),
//   email: Joi.string().email().required(),
//   password: Joi.string().min(3).max(255).required(),
//   privileges: Joi.string().min(1).max(255).required(),
// })

export const loginUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { body } = req
    const user = await userService.loginUser(body as ILoginCredentials)
    if (!user) {
      throw new CustomError('Login failed', 401)
    }
    res.json({ user, jwt: '12345abcde' })
  } catch (err) {
    next(err)
  }
}

export const getUsers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const users = await userService.getUsers()
    res.json({ users })
  } catch (err) {
    next(err)
  }
}
