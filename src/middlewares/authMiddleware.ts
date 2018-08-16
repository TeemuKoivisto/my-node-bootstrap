import { Request, Response, NextFunction } from 'express'

import { jwtService } from '../common/jwt.service'

import { CustomError } from '../common'

// import { IUser } from '../interfaces/user'
import { IAuthenticatedRequest } from '../interfaces/auth'

function parseJwtFromHeaders(req: Request) {
  if (req.headers.authorization && req.headers.authorization.toLowerCase().includes('bearer')) {
    return req.headers.authorization.split(' ')[1]
  }
  return null
}

export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  const jwtToken = parseJwtFromHeaders(req)
  if (!jwtToken) {
    next(new CustomError('Missing authorization header with Bearer token', 401))
  }
  const decrypted = jwtService.decryptSessionToken(jwtToken as string)
  if (decrypted.expires < Date.now()) {
    next(new CustomError('Token has expired', 401))
  } else {
    const mutatedReq = req as IAuthenticatedRequest
    mutatedReq.authenticatedUser = decrypted.user
    await next()
  }
}
