import { Request } from 'express'
import { IUser } from './user'

export interface IJwtPayload {
  expires: number
  user: IUser
}

export interface IAuthenticatedRequest extends Request {
  authenticatedUser: IUser
}
