import { dbService } from '../../db/db.service'

import { IUser, ILoginCredentials } from '../../interfaces/user'

export const userService = {
  loginUser: async (credentials: ILoginCredentials) => {
    const result = await dbService.queryOne(
      `SELECT id, name, email, privileges FROM app_user WHERE email=$1 AND password=$2`,
      [credentials.email, credentials.password])
    return result
  },
  getUsers: async () => {
    const users = await dbService.queryMany('SELECT id, name, email, privileges FROM app_user') as IUser[]
    return users
  }
}
