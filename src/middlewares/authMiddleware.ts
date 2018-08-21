import { Request, Response, NextFunction } from 'express'

import { jwtService } from '../common/jwt.service'

import { CustomError } from '../common'

// import { IUser } from '../interfaces/user'
import { IAuthenticatedRequest, IJwtPayload } from '../interfaces/auth'

function parseJwtFromHeaders(req: Request) {
  if (req.headers.authorization && req.headers.authorization.toLowerCase().includes('bearer')) {
    return req.headers.authorization.split(' ')[1]
  }
  return null
}

export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  const jwtToken = parseJwtFromHeaders(req)
  if (!jwtToken) {
    // Without return this method would continue processing and genereate TWO errors
    // which the next wouldn't be caught by the errorHandler -> always remember to return next() in if
    return next(new CustomError('Missing authorization header with Bearer token', 401))
  }
  let decrypted: IJwtPayload | undefined
  try {
    decrypted = jwtService.decryptSessionToken(jwtToken as string)
  } catch (err) {
    return next(err)
  }
  if (decrypted && decrypted.expires < Date.now()) {
    next(new CustomError('Token has expired', 401))
  } else if (decrypted) {
    const mutatedReq = req as IAuthenticatedRequest
    mutatedReq.authenticatedUser = decrypted.user
    next()
  }
}
