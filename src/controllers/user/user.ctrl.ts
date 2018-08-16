import { Request, Response, NextFunction } from 'express'
import * as Joi from 'joi'
import { userService } from './user.service'
import { jwtService } from '../../common/jwt.service'

import { CustomError } from '../../common'

import { ILoginCredentials, IUserCreateParams } from '../../interfaces/user'
import { IAuthenticatedRequest } from '../../interfaces/auth'

export const USER_CREDENTIALS_SCHEMA = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).max(255).required(),
})

export const USER_CREATE_SCHEMA = Joi.object({
  name: Joi.string().min(1).max(255).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(8).max(255).required(),
  privileges: Joi.string().min(1).max(255).required(),
})

export const USER_SCHEMA = Joi.object({
  id: Joi.number().integer(),
  name: Joi.string().min(1).max(255).required(),
  email: Joi.string().email().required(),
  privileges: Joi.string().min(1).max(255).required(),
})

export const loginUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { body } = req
    const user = await userService.loginUser(body as ILoginCredentials)
    if (!user) {
      throw new CustomError('Login failed', 401)
    }
    const expires = jwtService.createSessionExpiration()
    res.json({
      user,
      jwt: {
        expires,
        token: jwtService.createSessionToken(user, expires)
      }
    })
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

export const createUser = async (req: IAuthenticatedRequest, res: Response, next: NextFunction) => {
  try {
    const user = await userService.createUser(req.body as IUserCreateParams)
    res.json({ user })
  } catch (err) {
    next(err)
  }
}
