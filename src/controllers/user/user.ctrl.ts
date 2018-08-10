import { Request, Response, NextFunction } from 'express'
import { userService } from './user.service'

import { CustomError } from '../../common'

import { ILoginCredentials } from '../../interfaces/user'

export const loginUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { body } = req
    if (!body.email || typeof body.email !== 'string' || body.email.length < 3) {
      throw new CustomError(`Email missing, not a string or less than 1 characters long `, 400)
    }
    if (!body.password || typeof body.password !== 'string' || body.password.length < 8) {
      throw new CustomError(`Password missing, not a string or less than 8 characters long `, 400)
    }
    const params = body as ILoginCredentials
    const user = await userService.loginUser(params)
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
